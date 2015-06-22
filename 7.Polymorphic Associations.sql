--描述：
--		使用双用途的外键
-- 下面创建了一张评论表，该表通过issue_id关联Bugs或者FeatureRequests表，通过issue_type表面关联的是哪一张表。这种一个外键对应两张表的模式就是多态关联或者杂乱关联。
CREATE TABLE Comments (
	comment_id SERIAL PRIMARY KEY,
	issue_type VARCHAR(20), -- "Bugs" or "FeatureRequests"
	issue_id BIGINT UNSIGNED NOT NULL,
	author BIGINT UNSIGNED NOT NULL,
	comment_date DATETIME,
	comment TEXT,
	FOREIGN KEY (author) REFERENCES Accounts(account_id)
);
-- 创建另一张需使用的表
CREATE TABLE FeatureRequests (
	issue_id SERIAL PRIMARY KEY,
	reported_by BIGINT UNSIGNED NOT NULL,
	product_id BIGINT UNSIGNED,
	priority VARCHAR (20),
	version_resolved VARCHAR (20),
	STATUS VARCHAR (20),
	sponsor VARCHAR (50),
	-- only for feature requests
	FOREIGN KEY (reported_by) REFERENCES Accounts (account_id),
	FOREIGN KEY (product_id) REFERENCES Product (product_id)
)

-- 问题1：issue_id不重视一个外键，因而没有办法保证每一个issue_id都是真实存在的。同样也没法保证issue_type都是对应一张真实存在的表的。

-- 问题2：使用多态关联进行查询
-- 要查找一条给定的评论对应的 Bug 记录或者特性需求，需要执行一条同时外联 Bugs 和FeatureRequests两张表的查询。但是仅有一张表的字段会显示出有值，我们需要的则是查询结果中的非空字段
SELECT
	*
FROM
	comments_polymorphic_associations t1
LEFT JOIN bugs t2 ON t1.issue_id = t2.bug_id AND t1.issue_type = 'Bugs'
LEFT JOIN featurerequests t3 ON t3.issue_id = t1.issue_id AND t1.issue_type = 'FeatureRequests'
WHERE t1.comment_id = 2;

-- 合理使用反模式：
-- 你应该尽可能地避免使用多态关联——应该使用外键约束等来确保引用完整性。多态关联通常过度依赖上层程序代码而不是数据库的元数据。当你使用一个面向对象的框架（诸如 Hibernate）时，多态关联似乎是不可避免的。这种类型的框架通过良好的逻辑封装来减少使用多态关联的风险。

-- 解决：让关系变得简单
-- 解决1：反向引用
-- 当你看清楚问题的根源时，解决方案将变得异常的简单： 多态关联是一个反向关联。

-- 解决2：创建交叉表
-- Comments 表中的外键无法同时引用多张父表，因而，我们使用多个外键同时引用 Comments表即可。为每个父表创建一张独立的交叉表，每张交叉表同时包含一个指向Comments的外键和一个指向对应父表的外键。
CREATE TABLE BugsComments (
	i ssue_id BIGINT UNSIGNED NOT NULL,
	comment_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (issue_id, comment_id),
	UNIQUE KEY (comment_id),
	FOREIGN KEY (issue_id) REFERENCES Bugs(issue_id),
	FOREIGN KEY (comment_id) REFERENCES Comments(comment_id)
);
CREATE TABLE FeaturesComments (
	issue_id BIGINT UNSIGNED NOT NULL,
	comment_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (issue_id, comment_id),
	UNIQUE KEY (comment_id),
	FOREIGN KEY (issue_id) REFERENCES FeatureRequests(issue_id),
	FOREIGN KEY (comment_id) REFERENCES Comments(comment_id)
);
-- 这个解决方案移除了对 Comments.issue_type 列的依赖。现在，元数据可以确保数据完整 性了，从而不再依赖于应用程序代码来维护数据间的关系。
-- 使用这个方法的时候，还需要注意的是，可以添加约束UNIQUE KEY (comment_id)来保证，一个评论只在交叉表中出现一次，但无法保证一个评论在多个交叉表中只出现一次，这部分功能需要通过程序来控制。

-- 解决3：使用连接查询
SELECT b.issue_id,
       b.description,
       b.reporter,
       b.priority,
       b.status,
       b.severity,
       b.version_affected,
       NULL AS sponsor
FROM Comments AS c
JOIN (BugsComments
      JOIN Bugs AS b USING (issue_id)) USING (comment_id)
WHERE c.comment_id = 9876；
UNION
SELECT f.issue_id,
       f.description,
       f.reporter,
       f.priority,
       f.status,
       NULL AS severity,
       NULL AS version_affected,
       f.sponsor
FROM Comments AS c
JOIN (FeaturesComments
      JOIN FeatureRequests AS f USING (issue_id)) USING (comment_id)
WHERE c.comment_id = 9876;
-- 另一种连接查询，使用COALESCE函数返回第一个非null的值
SELECT c. *,
       COALESCE(b.issue_id, f.issue_id) AS issue_id,
       COALESCE(b.description, f.description) AS description,
       COALESCE(b.reporter, f.reporter) AS reporter,
       COALESCE(b.priority, f.priority) AS priority,
       COALESCE(b.status, f.status) AS status,
       b.severity,
       b.version_affected,
       f.sponsor
FROM Comments AS c
LEFT OUTER JOIN (BugsComments
                 JOIN Bugs AS b USING (issue_id)) USING (comment_id)
LEFT OUTER JOIN (FeaturesComments
                 JOIN FeatureRequests AS f USING (issue_id)) USING (comment_id)
WHERE c.comment_id = 9876;