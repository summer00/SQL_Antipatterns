--描述：
--		存储多值属性
-- 一个属性（本例以给BUG添加标签为列）看上去属于一张表，但是存在多个值将多个值合并在一起并用逗号分隔导致难以对数据进行验证，难以读取或者改变单个值，同时也对聚合公式（诸如统计不同值的数量）非常不友好。学习过第二章，我们已经能够杜绝这种情况，所以本次要说明的反模式为使用多列存储这些值。
CREATE TABLE Bugs (
	bug_id SERIAL PRIMARY KEY,
	description VARCHAR(1000),
	tag1 VARCHAR(20),
	tag2 VARCHAR(20),
	tag3 VARCHAR(20)
);
INSERT INTO `bugs_multicolumn_attributes` VALUES (1, '用户输入密码后无法登陆', 'work', NULL, NULL);
INSERT INTO `bugs_multicolumn_attributes` VALUES (2, '在单包件采购页面，查询产品时，查询结果加载速度很慢', 'purchase', NULL, NULL);
INSERT INTO `bugs_multicolumn_attributes` VALUES (3, '在采购草稿箱中的产品提交成功后，该产品会自动从采购草稿箱中消失', 'purchase', NULL, NULL);
INSERT INTO `bugs_multicolumn_attributes` VALUES (4, '订单提交失败', 'submit', 'error', NULL);
INSERT INTO `bugs_multicolumn_attributes` VALUES (5, '无法选择产品', 'purchase', 'product', 'error');

-- 问题1：查询复杂
-- 当根据一个给定标签查询所有Bug记录时，你必须搜索所有的三列，因为这个标签字符串可能存放于这三列中的任何一列。
SELECT * FROM bugs_multicolumn_attributes
WHERE tag1 = 'PURCHASE' OR tag2 = 'PURCHASE' OR tag3 ='PURCHASE';
-- 要查询标签为多个值时更加复杂
SELECT * FROM bugs_multicolumn_attributes
WHERE (tag1 = 'PURCHASE' OR tag2 = 'PURCHASE' OR tag3 ='PURCHASE')
AND (tag1 = 'error' OR tag2 = 'error' OR tag3 ='error');

-- 问题2：添加及删除值
-- 当需要添加和删除一个标签的时候，这种方式也存在问题，我们必须先验证被更新的字段之前的值是否符合预期。
-- 删除work标签
UPDATE Bugs
SET tag1 = NULLIF(tag1, 'work'),
    tag2 = NULLIF(tag2, 'work'),
    tag3 = NULLIF(tag3, 'work')
WHERE bug_id = 1;
-- 新增work标签
-- 表达式将 performance 标签加到第一个空列中。然而，如果 3 列都不为空，这条语句将不对这条记录做任何修改，新的标签将不会被记录。同时，写这样的查询语句是非常繁琐耗时的，你必须要重复 performance 这个字符串 6 次！
UPDATE bugs_multicolumn_attributes
   SET tag1 = CASE
                WHEN 'work' IN (tag2, tag3) THEN tag1
                ELSE COALESCE(tag1, 'work') END,
       tag2 = CASE
                WHEN 'work' IN (tag1, tag3) THEN tag2
                ELSE COALESCE(tag2, 'work') END,
       tag3 = CASE
                WHEN 'work' IN (tag1, tag2) THEN tag3
                ELSE COALESCE(tag3, 'work') END
WHERE bug_id = 1;

-- 问题3：无法确保唯一性
-- 你并不能阻止在一条记录中插入重复的标签
INSERT INTO Bugs
  (description, tag1, tag2, tag3)
VALUES
  ('printing is slow', 'printing', 'performance', 'performance');

-- 问题4：无法扩展
-- 如果我们想要加入标签大于预先设定的3个时，我们需要对表进行重构。重构的时候可能会导致锁住整张表，并阻止那些并发客户端的访问；加入新的列，必须去检查之前的代码是否会受到影响；有些数据库是通过定义一张符合需求的新表，然后将现有数据从旧表中复制到新表中，再丢弃旧表的方式来实现重构表结构的。如果需要重构的表有很多数据，那转换过程将·非常耗时。

-- 合理使用反模式：
-- 在某些情况下，一个属性可能有固定数量的候选值，并且对应的存储位置和顺序都是固定的。例如在Bugs表中定义三个不同的列来存储创建人、解决人、验收人这三个属性是合理的。

-- 解决1：创建从属表
-- 如同在第二章中看到的一样，最好的解决方案是创建一张从属表，仅使用一列来存储多值属性，将多值属性存储在多行而不是多列中，在从表中添加外键，将这个值和Bugs表中的记录关联起来。
CREATE TABLE Tags_multicolumn_attributes (
	bug_id BIGINT UNSIGNED NOT NULL,
	tag VARCHAR(20),
	PRIMARY KEY (bug_id, tag),
	FOREIGN KEY (bug_id) REFERENCES Bugs_multicolumn_attributes(bug_id)
);
INSERT INTO Tags_multicolumn_attributes
  (bug_id, tag)
VALUES
  (1, 'crash'),
  (2, 'printing'),
  (2, 'performance');
-- 在这种情况下，查找一个指定标签的bug就变得简单起来了。
SELECT *
  FROM bugs_multicolumn_attributes T1
  JOIN Tags_multicolumn_attributes T2
    ON T1.bug_id = T2.BUG_ID
 WHERE T2.TAG = 'CRASH';
 -- 添加和删除标签也变得简单
INSERT INTO Tags_multicolumn_attributes (bug_id, tag) VALUES (2, 'save');

DELETE FROM Tags_multicolumn_attributes WHERE bug_id = 1 AND tag = 'crash';