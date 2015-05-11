--描述：
--		树形关系存储与查找
--		

--反模式：总是依赖父节点
--很多书籍或文章中，最常见的简单解决方案是添加parent_id字段，引用同一张表中的其他回复。可以建一个外键约束来维护这种关系。

--准备：创建评论表comments的新外建parent_id,使comments应用自己，这样的表设计叫做邻接表
ALTER TABLE comments ADD (parent_id bigint unsigned);
ALTER TABLE comments ADD
FOREIGN KEY comments_parents(parent_id) REFERENCES comments(comment_id);


--问题1：复杂的连接查询
--查询一个回复，并得到其直接回复（关联了账号表，查出回复人的姓名）
SELECT c3.account_name AS mainAuthor,
       c1.`COMMENT`,
       c4.account_name AS repeatAuthor,
       c2.`COMMENT`
FROM Comments c1
LEFT JOIN Comments c2 ON c2.parent_id = c1.comment_id
LEFT JOIN accounts c3 ON c3.account_id = c1.author
LEFT JOIN accounts c4 ON c4.account_id = c2.author;
--查询更多深度的回复
SELECT c1.author AS mainAuthor,
       c1.`COMMENT`,						--第一层
       c2.author AS repeatAuthor1,
       c2.`COMMENT`,						--第二层
       c3.author AS repeatAuthor2,
       c3.`COMMENT`,						--第三层
       c4.author AS repeatAuthor3,
       c4.`COMMENT`						--第四层
FROM Comments c1
LEFT JOIN Comments c2 ON c2.parent_id = c1.comment_id
LEFT JOIN Comments c3 ON c3.parent_id = c2.comment_id
LEFT JOIN Comments c4 ON c4.parent_id = c3.comment_id


--添加和修改一个节点，在这种结构中比较简单
INSERT INTO `comments` VALUES (13, 3, 1, '2015-5-11 14:48:03', '再次确认中', 12);
UPDATE 'comments' SET `COMMENT` = '已确认解决' WHERE comment_id = 13;


--问题2：删除一颗子树，是否复杂
--首先你的查询出所有子节点
SELECT comment_id FROM Comments WHERE parent_id = 8; -- returns 10 and 11
SELECT comment_id FROM Comments WHERE parent_id = 10; -- returns none
SELECT comment_id FROM Comments WHERE parent_id = 11; -- returns 12
SELECT comment_id FROM Comments WHERE parent_id = 12; -- returns 13
SELECT comment_id FROM Comments WHERE parent_id = 13; -- returns none
--然后 按顺序 删除每个节点
DELETE Comments WHERE parent_id = 13;
DELETE Comments WHERE parent_id = 12;
DELETE Comments WHERE parent_id in (11,12);
DELETE Comments WHERE parent_id = 8;
