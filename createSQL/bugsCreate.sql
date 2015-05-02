drop table if exists Accounts;

drop table if exists BugState;

drop table if exists Bugs;

drop table if exists BugsProducts;

drop table if exists Comments;

drop table if exists Products;

drop table if exists Screenshots;

drop table if exists Tags;
create table Accounts
(
   account_id           serial primary key,
   account_name         varchar(20),
   first_name           varchar(20),
   last_name            varchar(20),
   email                varchar(100),
   password_hash        char(64),
   protrait_image       BLOB,
   horly_rate           numeric(9,2)
);

/*==============================================================*/
/* Table: BugState                                              */
/*==============================================================*/
create table BugState
(
   status               varchar(20) primary key
   
);

/*==============================================================*/
/* Table: Bugs                                                  */
/*==============================================================*/
create table Bugs
(
   bug_id               serial primary key,
   date_reported        date not null,
   summary              varchar(80),
   description          varchar(1000),
   resolution           varchar(1000),
   reported_by          bigint unsigned not null,
   assigned_to          bigint unsigned,
   verified_by          bigint unsigned,
   status               varchar(20) not null default 'NEW',
   proiority            varchar(20),
   hours                numeric(9,2),
   foreign key (reported_by) references Accounts(account_id),
   foreign key (assigned_to) references Accounts(account_id),
   foreign key (verified_by) references Accounts(account_id),
   foreign key (status) references BugState(status)
);

/*==============================================================*/
/* Table: BugsProducts                                          */
/*==============================================================*/
create table BugsProducts
(
   bug_id               bigint unsigned not null,
   product_id           bigint unsigned not null,
   primary key (bug_id, product_id),
   foreign key (bug_id) references Bugs(bug_id),
   foreign key (product_id) references Products(product_id)
);

/*==============================================================*/
/* Table: Comments                                              */
/*==============================================================*/
create table Comments
(
   comment_id           serial primary key,
   bug_id               bigint unsigned not null,
   author               bigint unsigned not null,
   comment_date         datetime not null,
   comment              text not null,
   foreign key (bug_id) references Bugs(bug_id),
   foreign key (author) references Accounts(account_id)
);

/*==============================================================*/
/* Table: Products                                              */
/*==============================================================*/
create table Products
(
   product_id           serial primary key,
   product_name         varchar(50)
);

/*==============================================================*/
/* Table: Screenshots                                           */
/*==============================================================*/
create table Screenshots
(
   bug_id               bigint unsigned not null,
   image_id             bigint unsigned not null,
   screenshot_image     blob,
   caption              varchar(100),
   primary key (bug_id, image_id),
   foreign key (bug_id) references Bugs(bug_id)
);

/*==============================================================*/
/* Table: Tags                                                  */
/*==============================================================*/
create table Tags
(
   bug_id               bigint unsigned not null,
   tag                  varchar(20) not null,
   primary key (bug_id, tag),
   foreign key (bug_id) references Bugs(bug_id)
);
/*账户*/
INSERT INTO `accounts` VALUES (1, 'xia', 'x', 'x', 'xia@123.com', '123', NULL, 1.00);
INSERT INTO `accounts` VALUES (2, 'pen', 'p', 'p', 'pen@123.com', '123', NULL, 2.00);
INSERT INTO `accounts` VALUES (3, 'chen', 'c', 'c', 'chen@123.com', '123', NULL, 3.00);
INSERT INTO `accounts` VALUES (4, 'zhang', 'z', 'z', 'zhang@123.com', '123', NULL, 4.00);
INSERT INTO `accounts` VALUES (5, 'li', 'l', 'l', 'li@123.com', '123', NULL, 5.00);

/*BUG状态*/
INSERT INTO `bugstate` VALUES ('DONE');
INSERT INTO `bugstate` VALUES ('NEW');
INSERT INTO `bugstate` VALUES ('UN');

/*BUG*/
INSERT INTO `bugs` VALUES (1, '2015-5-12', NULL, '无', '', 1, 2, 3, 'NEW', '2', 6.00);
INSERT INTO `bugs` VALUES (2, '2015-5-12', NULL, '无', '', 1, 2, 3, 'NEW', '1', 6.00);
INSERT INTO `bugs` VALUES (3, '2015-5-12', NULL, '无', '', 1, 2, 3, 'NEW', '3', 6.00);
INSERT INTO `bugs` VALUES (4, '2015-5-12', NULL, '无', '', 1, 2, 3, 'NEW', '2', 6.00);
INSERT INTO `bugs` VALUES (5, '2015-5-12', NULL, '无', '', 1, 2, 3, 'NEW', '2', 6.00);