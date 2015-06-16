--描述：
--		支持可变属性


--反模式：使用泛型属性表
-- 对于某些程序员来说，当他们需要支持可变属性时，第一反应便是创建另一张表，将属性当成行来存储。这样的设计称为实体—属性—值，简称EAV。有时也称之为：开放架构、无模式或者名-值对。
--相关概念：
	-- ■ 实体：通常来说这就是一个指向父表的外键，父表的每条记录表示一个实体对象
	-- ■ 属性：在传统的表中，属性即每一列的名字，但在这个新的设计中，我们需要根据不同的记录来解析其标识的对象属性。 
	-- ■ 值：对于每个实体的每一个不同属性，都有一个对应的值。
--创建表语句：
--问题表
CREATE TABLE Issues (issue_id SERIAL PRIMARY KEY);
INSERT INTO Issues (issue_id) VALUES (1234);
INSERT INTO Issues (issue_id) VALUES (1235);
--问题属性表
CREATE TABLE IssueAttributes (
	issue_id BIGINT UNSIGNED NOT NULL,
	attr_name VARCHAR (100) NOT NULL,
	attr_value VARCHAR (100),
	PRIMARY KEY (issue_id, attr_name),
	FOREIGN KEY (issue_id) REFERENCES Issues (issue_id)
);
INSERT INTO IssueAttributes ( issue_id, attr_name, attr_value)
VALUES	(1234, 'product', '1'),
		(1234, 'date_reported', '2009-06-01'),
		(1234, 'status', 'NEW'),
		(1234, 'description', 'Saving does not work'),
		(1234, 'reported_by', 'Bill'),
		(1234, 'version_affected', '1.0'),
		(1234, 'severity', 'loss of functionality'),
		(1234, 'priority', 'high');
INSERT INTO IssueAttributes ( issue_id, attr_name, attr_value)
VALUES	(1235, 'product', '2'),
		(1235, 'date_reported', '2010-06-01'),
		(1235, 'status', 'NEW'),
		(1235, 'description', 'Saving does not work'),
		(1235, 'reported_by', 'ddd'),
		(1235, 'version_affected', '1.0'),
		(1235, 'severity', 'loss of functionality'),
		(1235, 'priority', 'high');

--反模式好处：
--  这两张表的列都很少。
--  新增的属性不会对现有的表结构造成影响，不需要新增列。
--  避免了由于空值而造成的表内容混乱。

--问题1：查询属性变得很复杂
--普通设计
SELECT issue_id, date_reported FROM Issues;
--EAV
SELECT issue_id,
       attr_value AS "date_reported"
FROM IssueAttributes
WHERE attr_name = 'date_reported'
  AND attr_value > '2010-01-01';
--问题2：支持数据完整性
--问题3：无法声明强制属性，无法确保每个实体都有相同的属性
--问题4：无法使用SQL的数据类型，可能用每个类型设置一个列，不需用就空着，但也不能完全解决，且查询语句变复杂
--问题5：无法确保引用完整性。你可以定义一个指向另一张表的外键来约束某些属性的取值范围。 比如，一个Bug 或者事件的 status 属性应该是一张很小的 BugStatus 表中的一个值。在EAV的设计中，你无法在attr_value列上使用这种约束方法。引用完整性的约束会应用到表中的每一行。
--问题6：无法配置属性名。无法保证每个实体的相同意思的列的命名都相同。
SELECT date_reported,
       COUNT(*) AS bugs_per_date
FROM
  ( SELECT DISTINCT attr_value AS date_reported
   FROM IssueAttributes
   WHERE attr_name IN ( 'date_reported',
                        'report_date' ) ) AS v1
GROUP BY date_reported;
--问题7：重组为普通形式变得困难
SELECT i.issue_id,
       i1.attr_value AS "date_reported",
       i2.attr_value AS "status",
       i3.attr_value AS "priority",
       i4.attr_value AS "description",
       i5.attr_value AS "VERSION"
FROM Issues AS i
LEFT OUTER JOIN IssueAttributes AS i1 ON i.issue_id = i1.issue_id AND i1.attr_name = 'date_reported'
LEFT OUTER JOIN IssueAttributes AS i2 ON i.issue_id = i2.issue_id AND i2.attr_name = 'status'
LEFT OUTER JOIN IssueAttributes AS i3 ON i.issue_id = i3.issue_id AND i3.attr_name = 'priority'
LEFT OUTER JOIN IssueAttributes AS i4 ON i.issue_id = i4.issue_id AND i4.attr_name = 'description'
LEFT OUTER JOIN issueattributes AS i5 ON i.issue_id = i5.issue_id AND i5.attr_name = 'version_affected'
WHERE i.issue_id = 1234 OR i.issue_id = 1235;

--合理的使用
--基本上在关系型数据库中无法使用这种设计模式。要采用不定的属性的存储数据的形式时，通常要采用非关系型数据库（NoSQL）。

-- 解决1：单表继承
-- 最简单的设计是将所有相关的类型都存在一张表中，为所有类型的所有属性都保留一列。问题是拓展性不好。在子类很少，以及子类特殊性很少的情况下可以选择这种实现方式。
--限制：1，每张表的列数有限制；2，没有任何标记来标记每个列属于哪个子类型。

--解决2：实体表继承
--为每一个子类型都创建一张单独的表，表中包含公共字段和特有字段。当很少一次性查询所有子类型时，是体表继承是一个好办法。
--限制：1，无法确定表中那些字段是公共的，若公共字段添加，所有子类型表都要添加这个字段;2，当不区分子类型只查询公共字段的时候，需要建立一些复杂的视图（如下）解决。
CREATE VIEW Issues AS
SELECT b. *, 'bug' AS issue_type
FROM Bugs AS b
UNION ALL
SELECT f. *, 'feature' AS issue_type
FROM FeatureRequests AS f;

--解决三：类表继承
-- 创建一张基类表，包含所有子类型的公共属性。对于每个子类型，创建一个独立的表，通过外键和基类表相连。
CREATE TABLE Issues (
	i ssue_id SERIAL PRIMARY KEY,
	reported_by BIGINT UNSIGNED NOT NULL,
	product_id BIGINT UNSIGNED,
	priority VARCHAR(20),
	version_resolved VARCHAR(20),
	status VARCHAR(20),
	FOREIGN KEY (reported_by) REFERENCES Accounts(account_id),
	FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
CREATE TABLE Bugs (
	issue_id BIGINT UNSIGNED PRIMARY KEY,
	severity VARCHAR(20),
	version_affected VARCHAR(20),
	FOREIGN KEY (issue_id) REFERENCES Issues(issue_id)
);
CREATE TABLE FeatureRequests (
	issue_id BIGINT UNSIGNED PRIMARY KEY,
	sponsor VARCHAR(50),
	FOREIGN KEY (issue_id) REFERENCES Issues(issue_id)
);
-- 查询时使用连表查询也比较方便
SELECT i. *,b. *,f. *
FROM Issues AS i
LEFT OUTER JOIN Bugs AS b USING (issue_id)
LEFT OUTER JOIN FeatureRequests AS f USING (issue_id);

--解决四：半结构化的数据模型
-- 如果你有很多子类型或者你必须经常地增加新的属性支持，那么可以使用一个 BLOB 列来存储数据，用 XML 或者 JSON 格式——同时包含了属性的名字和值。 Martin Fowler 称这个模式为：序列化大对象块（Serialized LOB）。这个设计的优势之处就在于其优异的扩展性。该设计的缺点就是在这样的一个结构中， SQL 基本上没有办法获取某个指定的属性。当需要绝对灵活的设计的时候可以使用这个方案。