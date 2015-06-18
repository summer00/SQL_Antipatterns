--描述：
--		存储多值属性
--一个属性（本例以给BUG添加标签为列）看上去属于一张表，但是存在多个值将多个值合并在一起并用逗号分隔导致难以对数据进行验证，难以读取或者改变单个值，同时也对聚合公式（诸如统计不同值的数量）非常不友好。学习过第二章，我们已经能够杜绝这种情况，所以本次要说明的反模式为使用多列存储这些值。
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

--问题1：查询复杂
--当根据一个给定标签查询所有Bug记录时，你必须搜索所有的三列，因为这个标签字符串可能存放于这三列中的任何一列。
SELECT * FROM bugs_multicolumn_attributes
WHERE tag1 = 'PURCHASE' OR tag2 = 'PURCHASE' OR tag3 ='PURCHASE';
--要查询标签为多个值时更加复杂
SELECT * FROM bugs_multicolumn_attributes
WHERE (tag1 = 'PURCHASE' OR tag2 = 'PURCHASE' OR tag3 ='PURCHASE')
AND (tag1 = 'error' OR tag2 = 'error' OR tag3 ='error');

--问题2：添加及删除值
--当需要添加和删除一个标签的时候，这种方式也存在问题，我们必须先验证被更新的字段之前的值是否符合预期。
UPDATE Bugs
SET tag1 = NULLIF(tag1, 'performance'),
    tag2 = NULLIF(tag2, 'performance'),
    tag3 = NULLIF(tag3, 'performance')
WHERE bug_id = 3456;