SQL复制表的几种方法：

SQL复制整张表

Select * Into New_Table_Name From Old_Table_Name;
只复制列名而不要内容

Select * Into New_Table_Name From Old_Table_Name Where 1 = 0;
表间数据复制

Insert Into New_Table_Name Select * From Old_Table_Name;