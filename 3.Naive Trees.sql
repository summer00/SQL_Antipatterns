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


--合适的使用场景
--某些情况下，在应用程序中使用邻接表设计可能正好适用。邻接表设计的优势在于能快速地获取一个给定节点的直接父子节点，它也很容易插入新节点。如果这样的需求就是你的应用程序对于分层数据的全部操作，那使用邻接表就可以很好地工作了。
--注：若能事先知晓树的深度，则可以更好的设计。

--解决1：使用‘路径枚举’解决获取给定节点的所有祖先开销大问题
--添加字段path，用来记录当前节点的路径
ALTER TABLE comments ADD (path VARCHAR(1000));
--修改后插入数据
INSERT INTO `comments` VALUES (6, 3, 1, '2015-5-11 14:43:44', '如何形成的？', NULL, '6/');
INSERT INTO `comments` VALUES (7, 3, 2, '2015-5-11 14:44:54', '空指针', 6, '6/7');
INSERT INTO `comments` VALUES (8, 3, 3, '2015-5-12 14:45:14', '输入异常', 6, '6/8');
INSERT INTO `comments` VALUES (9, 3, 1, '2015-5-11 14:46:17', '不我确认过了', 7, '6/7/9');
INSERT INTO `comments` VALUES (10, 3, 2, '2015-5-11 14:46:43', '是的，我查一下', 8, '6/8/10');
INSERT INTO `comments` VALUES (11, 3, 1, '2015-5-11 14:47:15', '好，查一下', 8, '6/8/11');
INSERT INTO `comments` VALUES (12, 3, 3, '2015-5-11 14:48:03', '解决', 11, '6/8/11/12');
INSERT INTO `comments` VALUES (13, 3, 1, '2015-5-11 14:48:03', '已确认解决', 12, '6/8/11/12/13');
--你可以通过比较每个节点的路径来查询一个节点的祖先。比如，要找到评论#12(路径6/8/11/12)的所有祖先，可以这样做
SELECT * FROM Comments AS c WHERE '6/8/11/12' LIKE CONCAT(c.path,'%');
--调转like两边，即查询一个给定节点的所有后代，如查询6/8的所有后代
SELECT * FROM Comments AS c WHERE c.path LIKE '6/8%'
--一旦你可以很简单地获取一棵子树或者从子孙节点到祖先节点的路径，就可以很简单地实现更多的查询，比如计算一棵子树所有节点上的值的总和（使用 SUM 聚合函数），或者仅仅是单纯地计算节点的数量。如果要计算从评论#8扩展出的所有评论中每个用户的评论数量，可以这样做
SELECT a.account_name,
       COUNT(*)
FROM Comments AS c
LEFT JOIN accounts a ON a.account_id = c.author
WHERE c.path LIKE '6/8%'
GROUP BY a.account_name;

--总结：
设计    表   查询子   查询树   插入   删除   引用完整性  已学
邻接表   1   简单      困难    简单   简单      是        √
递归查询 1   简单      简单    简单   简单      是        √
枚举路径 1   简单      简单    简单   简单      否        √
嵌套集   1   困难      简单    困难   困难      否
闭包表   2   简单      简单    简单   简单      是

 ■ 邻接表是最方便的设计，并且很多软件开发者都了解它。
 ■ 如果你使用的数据库支持 WITH 或者 CONNECT BY PRIOR 的递归查询，那能使得邻接表的查询更为高效。
 ■ 枚举路径能够很直观地展示出祖先到后代之间的路径，但同时由于它不能确保引用完整性，使得这个设计非常地脆弱。枚举路径也使得数据的存储变得比较冗余。
 ■ 嵌套集是一个聪明的解决方案——但可能过于聪明了，它不能确保引用完整性。最好在一个查询性能要求很高而对其他需求要求一般的场合来使用它
 ■ 闭包表是最通用的设计，并且本章所描述的设计中只有它能允许一个节点属于多棵树。它要求一张额外的表来存储关系，使用空间换时间的方案减少操作过程中由冗余的计算所造成的消耗。