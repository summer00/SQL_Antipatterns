/*
	**************************bugStates*********************
NEW 
	—— 当REPORTER新提交一个BUG,不给其指派所有者的时候,
	BUG的状态会自动的成为NEW的状态.
FEEDBACK 
	—— 要求REPORTER再次对BUG进行说明
ACKNOWLEDGED 
	—— 开发人员解决了BUG以后QA已经了解但是还没有来得及
	确认
CONFIRMED 
	—— BUG的解决方案得到了QA的确认（如果你们的MANTIS是挂
	在网上同时用于CUSTOMER的ISSUE反馈的话，CONFIRMED可以
	理解成客户反
 */  
INSERT INTO `bugstatus` VALUES ('ACKNOWLEDGED');
INSERT INTO `bugstatus` VALUES ('CONFIRMED');
INSERT INTO `bugstatus` VALUES ('FEEDBACK');
INSERT INTO `bugstatus` VALUES ('NEW');


/***************************accounts**********************/
INSERT INTO `accounts` VALUES (1, '王小明', '王', '小明', 'xiaoming@163.com', '123', NULL, 2.00);
INSERT INTO `accounts` VALUES (2, '张佳佳', '张', '佳佳', 'jj@163.com', '123', NULL, 3.00);
INSERT INTO `accounts` VALUES (3, '李四', '李', '四', 'lisi@163.com', '123', NULL, 1.00);
INSERT INTO `accounts` VALUES (4, '赵庆', '赵', '庆', 'zhaoqing@163.com', '123', NULL, 3.00);
INSERT INTO `accounts` VALUES (5, '江楼', '江', '楼', 'jiang@163.com', '123', NULL, 2.00);


/***************************bugs*************************/
INSERT INTO `bugs` VALUES (1, '2015-5-1', '用户无法登陆', '用户输入密码后无法登陆', NULL, 1, 2, 3, 'ACKNOWLEDGED', '1', 5);
INSERT INTO `bugs` VALUES (2, '2015-5-2', '查询优化', '在单包件采购页面，查询产品时，查询结果加载速度很慢', NULL, 1, 2, 3, 'FEEDBACK', '1', NULL);
INSERT INTO `bugs` VALUES (3, '2015-5-1', '采购草稿箱提交后产品未消失', '在采购草稿箱中的产品提交成功后，该产品会自动从采购草稿箱中消失', NULL, 3, 2, NULL, 'CONFIRMED', '2', 3);
INSERT INTO `bugs` VALUES (4, '2015-5-2', '订单提交失败', '订单提交失败', NULL, 2, 2, NULL, 'CONFIRMED', '1', NULL);
INSERT INTO `bugs` VALUES (5, '2015-5-4', '无法选择产品', '无法选择产品', NULL, 1, 2, NULL, 'CONFIRMED', '1', 1);


/***************************tags*************************/
INSERT INTO `tags` VALUES (1, '错误');
INSERT INTO `tags` VALUES (2, 'SQL性能');
INSERT INTO `tags` VALUES (2, '优化');


/***************************comments*********************/
INSERT INTO `comments` VALUES (1, 1, 1, '2015-5-2 20:11:19', '请迅速修复', NULL);
INSERT INTO `comments` VALUES (2, 2, 1, '2015-5-2 20:11:19', '修复中！！', NULL);
INSERT INTO `comments` VALUES (3, 1, 2, '2015-5-2 20:11:19', '请迅速修复', NULL);
INSERT INTO `comments` VALUES (4, 1, 3, '2015-5-2 20:11:19', '无法重现', NULL);
INSERT INTO `comments` VALUES (5, 1, 4, '2015-5-2 20:11:19', '已确认，请查证', NULL);
INSERT INTO `comments` VALUES (6, 3, 1, '2015-5-11 14:43:44', '如何形成的？', NULL);
INSERT INTO `comments` VALUES (7, 3, 2, '2015-5-11 14:44:54', '空指针', 6);
INSERT INTO `comments` VALUES (8, 3, 3, '2015-5-12 14:45:14', '输入异常', 6);
INSERT INTO `comments` VALUES (9, 3, 1, '2015-5-11 14:46:17', '不我确认过了', 7);
INSERT INTO `comments` VALUES (10, 3, 2, '2015-5-11 14:46:43', '是的，我查一下', 8);
INSERT INTO `comments` VALUES (11, 3, 1, '2015-5-11 14:47:15', '好，查一下', 8);
INSERT INTO `comments` VALUES (12, 3, 3, '2015-5-11 14:48:03', '解决', 11);


/***************************screenshots******************/
INSERT INTO `screenshots` VALUES (2, 2, NULL, '222');
INSERT INTO `screenshots` VALUES (1, 1, NULL, '111');
INSERT INTO `screenshots` VALUES (2, 3, NULL, '333');


/***************************product**********************/
INSERT INTO `product` VALUES (1, '采购', '1,3');
INSERT INTO `product` VALUES (2, '草稿箱', '3,5');
INSERT INTO `product` VALUES (3, '销售', '4');
INSERT INTO `product` VALUES (4, 'Visual TurboBuilder', '1,2,3');


/*************************bugsproducts*******************/
INSERT INTO `bugsproducts` VALUES (1, 1);
INSERT INTO `bugsproducts` VALUES (2, 1);
INSERT INTO `bugsproducts` VALUES (3, 2);
INSERT INTO `bugsproducts` VALUES (4, 3);
INSERT INTO `bugsproducts` VALUES (5, 3);
