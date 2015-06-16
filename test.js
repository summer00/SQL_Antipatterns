var detailState =	[
							    { "id": 0, "text": "审图中" }, 
		    					{ "id": 1, "text": "审图通过" }, 
		    					{ "id": 2, "text": "审图未通过" }, 
		    					{ "id": 3, "text": "图纸已确认" }, 
		    					{ "id": 4, "text": "图纸已拒绝" }, 
		    					{ "id": 5, "text": "已报价" },
		    					{ "id": 6, "text": "初审退回" },
		    					{ "id": 9, "text": "资料已回传" },
		    					{ "id": 10, "text": "图纸确认提交BPM中" },
								{ "id": 11, "text": "图纸拒绝提交BPM中" },
								{ "id": 21, "text": "报价提交BPM成功" },
						    ];
创建流程时回调，需求编码，从表ID，状态传0
图纸确认时回调，需求编码，从表ID，状态传，20
报价确认时回调，需求编码，从表ID，状态传，21
var state =	[
					    { "id": 0, "text": "未提交" },
					    { "id": 1, "text": "已报审" },
					    { "id": 2, "text": "审图中" },
					    { "id": 3, "text": "初审退回" },
					    { "id": 4, "text": "已报价" },
						{ "id": 5, "text": "报价已确认" },
						{ "id": 6, "text": "报价已拒绝" },
						{ "id": 7, "text": "初审提交BPM中"},
						{ "id": 8, "text": "报价确认提交BPM中"},
						{ "id": 9, "text": "报价拒绝提交BPM中"}
				    ];cuschestDemand/cuschestDemandDetails
				    com.quanyou.cop.tbm.ws.client.customize.toBPM
{B_顾客地址=北京市市辖区东城区靖西南路小而香子区, B_产品名称=123, B_送货时间=2015-06-25, B_颜色=象牙白, B_产品编码=null, B_需求ID=8661, strSummary=, B_图纸类别=2020, B_顾客电话=null, B_门店名称=河南省登封市薛铁锋, B_申请单位编码=1020, B_申请单号=X1000325150605001, B_申请单位=河南直营办事处 , B_申请时间=2015-06-05, B_顾客姓名=null, B_备注=null, nIncidentNo=0, B_设计师姓名=test2, B_设计师电话=15757345233, B_门店电话=0371-67302666, B_产品类别=定制衣柜/成品/门板, B_原图纸=http://10.10.1.178:8080/default/customize/common/downloadDocument.jsp?path=D:/upload/doc/2015/06/05/1433483828106019356.txt, B_数量=1, strUserName=Ultimus/tbm}
{B_申请单号=X1000325150605002, B_需求ID=8681}