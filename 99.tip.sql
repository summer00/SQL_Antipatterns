-- 1.SQL复制表的几种方法：

-- SQL复制整张表:
Select * Into New_Table_Name From Old_Table_Name;
-- 只复制列名而不要内容:
Select * Into New_Table_Name From Old_Table_Name Where 1 = 0;
-- 表间数据复制:
Insert Into New_Table_Name Select * From Old_Table_Name;

-- 2.删除指定字段重复的数据：
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