-- 描述：限定列的有效值

-- 将一列的有效字段值约束在一个固定的集合内是非常有用处的。如果我们可以确保一列中永远不会包含无效字段，那对于使用方来说，逻辑会变得非常简单。

-- 反模式：在列定义上指定可选值
CREATE TABLE Bugs (
-- other columns
status VARCHAR(20) CHECK (status IN ('NEW' , 'IN PROGRESS' , 'FIXED' ))
);
-- 在mySql中可以使用ENUM方式约束一列的取值范围
CREATE TABLE Bugs (
-- other columns
status ENUM('NEW' , 'IN PROGRESS' , 'FIXED' ),
);

-- 问题1：
-- 要获得所有允许输入的 status 候选值，你需要查询这一列的元数据。大多数SQL数据库支持使用系统视图来完成这种查询需求，但是使用起来是很复杂的。比如，如果你使用MySQL的ENUM类型，可以使用如下的查询语句来查询 INFORMATION_SCHEMA 系统视图：
SELECT column_type
FROM information_schema.columns
WHERE table_schema = 'bugtracker_schema'
  AND TABLE_NAME = 'bugs'
  AND COLUMN_NAME = 'status' ;
-- 并且，对于获取Check约束、域或者UDT信息的查询来说，过程会更加复杂。大多数开发人员非常勇敢地在程序中手动维护这样一个列表。当程序数据和数据库的元数据不同步时，程序很容易就崩溃了。