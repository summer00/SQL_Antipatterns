--描述：
--		开始我们构建账户和产品是一对一关系，但随着项
--		目日趋成熟，需要改为一对多的对应关系

--反模式:
--		我们使用一个字段，存储多个值，中间用[，]分割		

--创建建有多个账户的产品
INSERT INTO Product (product_id, product_name, account_id)
VALUES (DEFAULT,
        'Visual TurboBuilder' ,
        '1,3');

--查询指定账号的产品
SELECT * FROM product WHERE account_id LIKE '%12%';
SELECT * FROM Product WHERE account_id REGEXP '[[:<:]]12[[:>:]]';

--查询指定产品的账号--Querying Accounts for a Given Product
--使用下面的语句测试时不能查询出正确的结果。在程序中，可以使用IN来查询
SELECT *
FROM Products AS p
JOIN Accounts AS a ON p.account_id REGEXP '[[:<:]]' || a.account_id || '[[:>:]]'
WHERE p.product_id = 123;

--执行聚合查询--Making Aggregate Queries
--使用下面的语句得到每个产品有多少账号，但是很复杂也不直观
SELECT product_id,
       LENGTH(account_id) - LENGTH(REPLACE(account_id, ',' , '')) + 1 AS contacts_per_product
FROM Products;

--跟新指定产品的账号--Updating Accounts for a Specific Product
--使用字符串链接可以将指定的账号添加到原账号的末尾，但这样做则没法保证该
--字段的排序
UPDATE Product
SET account_id = CONCAT(account_id,',',3)
WHERE product_id = 4;

--引发的其他问题
--1、数据验证：无法验证账号字段里的非法字符（pp:在程序验证还是数据库？）
--2、分隔符选择：当想要插入多个值的列为字符串时，很难选择一个恰当的分隔符
--3、长度选择：要的放入列需要设置一个长度，但是我们几乎不可能设置一个合适的值


--可以使用的地方
--  应用程序可能会需要逗号分隔的这种存储格式，也可能没必要获取列表中的单独项。同样，
--  如果应用程序接收的源数据是有逗号分隔的格式，而你只需要存储和使用它们并且不对其做
--  任何修改，完全没必要分开其中的值


--解决
-- 我们可以建立一张中间表（交叉表）
CREATE TABLE Contacts (
	product_id BIGINT UNSIGNED NOT NULL,
	account_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (product_id, account_id),
	FOREIGN KEY (product_id) REFERENCES Products(product_id),
	FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);
INSERT INTO `contacts` VALUES (1, 1);
INSERT INTO `contacts` VALUES (1, 3);
INSERT INTO `contacts` VALUES (2, 3);
INSERT INTO `contacts` VALUES (3, 4);
INSERT INTO `contacts` VALUES (4, 1);
INSERT INTO `contacts` VALUES (2, 5);
INSERT INTO `contacts` VALUES (4, 2);
INSERT INTO `contacts` VALUES (4, 3);


--查询指定账号的产品
SELECT p.*
FROM product AS p
JOIN contacts AS c ON c.product_id = p.product_id
WHERE c.account_id = 3;

--查询指定产品的账号
SELECT a.*
FROM accounts AS a
JOIN contacts AS c ON c.account_id = a.account_id
WHERE c.product_id = 2;

--执行聚合函数
--每个产品相关的账号数量
SELECT product_id, COUNT(*) AS account_num FROM contacts GROUP BY product_id;
--每个账号相关的产品数量
SELECT account_id, COUNT(*) FROM contacts GROUP BY account_id;

--其他好处：可以进行ID验证，不需鉴别分隔符，不用限制列长，可以建索引提高查询效率，
--		   还可以在交叉表中记录其他数据

--总结:每个值都应该存储在各自的行与列中