1.SQL复制表的几种方法：
-- SQL复制整张表:
Select * Into New_Table_Name From Old_Table_Name;
-- 只复制列名而不要内容:
Select * Into New_Table_Name From Old_Table_Name Where 1 = 0;
-- 表间数据复制:
Insert Into New_Table_Name Select * From Old_Table_Name;

2.删除指定字段重复的数据：
-- 添加ID
ALTER TABLE T_TBM_CUSTOMER ADD Id int Identity(1,1);
-- 删除重复，保存ID最小的
DELETE
FROM T_TBM_CUSTOMER
WHERE ID NOT IN(
	SELECT MIN(ID) FROM T_TBM_CUSTOMER
    GROUP BY CUST_NAME, CUST_CONTACT_PHONE, SHOP_CODE, CREATED_BY, UPDATED_BY);
-- 移除ID
ALTER TABLE T_TBM_CUSTOMER DROP COLUMN id;


3.TRUNCATE TABLE 和 DELETE TABLE 之间的区别：
1)TRUNCATE在各种表上无论是大的还是小的都非常快。如果有ROLLBACK命令Delete将被撤销，而TRUNCATE则不会被撤销。 
2)TRUNCATE是一个DDL语言，向其他所有的DDL语言一样，他将被隐式提交，不能对TRUNCATE使用ROLLBACK命令。 
3)TRUNCATE将重新设置高水平线和所有的索引。在对整个表和索引进行完全浏览时，经过TRUNCATE操作后的表比Delete操作后的表要快得多。 
4)TRUNCATE不能触发任何Delete触发器。 
5)当表被清空后表和表的索引讲重新设置成初始大小，而delete则不能。 
6)不能清空父表。

在oracle里,使用delete删除数据以后，数据库的存储容量不会减少，而且使用delete删除某个表的数据以后，查询这张表的速度和删除之前一样，不会发生变化。

因为oralce有一个HWM高水位，它是oracle的一个表使用空间最高水位线。当插入了数据以后，高水位线就会上涨，但是如果你采用delete语句删除数据的话，数据虽然被删除了，但是高水位线却没有降低，还是你刚才删除数据以前那么高的水位。除非使用truncate删除数据。那么，这条高水位线在日常的增删操作中只会上涨，不会下跌，所以数据库容量也只会上升，不会下降。而使用select语句查询数据时，数据库会扫描高水位线以下的数据块，因为高水位线没有变化，所以扫描的时间不会减少，所以才会出现使用delete删除数据以后，查询的速度还是和delete以前一样。