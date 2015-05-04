--描述：
--		开始我们构建账户和产品是一对一关系，但随着项
--		目日趋成熟，需要改为一对多的对应关系

-----------------------------------------------------------------------------
--反模式:
--		我们使用一个字段，存储多个值，中间用[，]分割		

--创建建有多个账户的产品
INSERT INTO Product (product_id, product_name, account_id)
VALUES (DEFAULT,
        'Visual TurboBuilder' ,
        '12,34');

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
-----------------------------------------------------------------------------