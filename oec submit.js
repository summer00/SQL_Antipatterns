listAddRecord.pop();
var diary1 = {
	Objectachievement : "TBM系统上线支持",
	end_time: "12:00",
	start_time: "09:00",
	state: "2",
	task_des: "TBM系统上线支持",
	task_type: 4,
	achievement:"TBM系统上线支持"
};
var diary2={
	Objectachievement : "TBM上线支持",
	end_time: "18:00",
	start_time: "13:00",
	state: "2",
	task_des: "TBM上线支持",
	task_type: 4,
	achievement:"TBM上线支持"
};
listAddRecord.push(diary1);
listAddRecord.push(diary2);
strJson:[{"start_time":"09:00","end_time":"12:00","task_type":4,"state":"2","task_des":"TBM系统开发","achievement":"TBM系统开发"},{"start_time":"13:00","end_time":"18:00","task_type":4,"state":"2","task_des":"TBM系统开发","achievement":"TBM系统开发"}]

var json = [{"start_time":"09:00","end_time":"12:00","task_type":4,"state":"2","task_des":"TBM系统开发","achievement":"TBM系统开发"},{"start_time":"13:00","end_time":"18:00","task_type":4,"state":"2","task_des":"TBM系统开发","achievement":"TBM系统开发"}];

strJson:[{"start_time":"09:30","end_time":"12:00","task_type":4,"state":"2","task_des":"TBM系统功能完善","achievement":"TBM系统功能完善"}]
proposal:
dayHead.dispose:
dayHead.category:
dayHead.minCategory:
dateTime:2015-04-26
type:1
dayHeadId:-1
vacation:N
businessTrip:N
Ext.Ajax.request({
					url : '/day/saveDay.do?tabID=iframe_module_tab_xnode-63',
					method : 'post',
					params : {
						strJson : Ext.encode(listAddRecord),
						proposal : proposal.getValue(),
						'dayHead.dispose' : dispose.getValue(),
						'dayHead.category' : categoryCom.getValue(),
						'dayHead.minCategory' : minCategoryCom.getValue(),
						dateTime : datetime.value,
						type : saveType,
						dayHeadId : dayHeadId = dayHeadId == false ? -1
								: dayHeadId,
						vacation : isVacation,
						businessTrip : isBusinessTrip
					},
					success : function(action) {

						var result = Ext.util.JSON.decode(action.responseText);
						if (!result.error) {
							dayHeadId = result.dayHeadId;
							if (saveType != 0) {
								top.removePanel(tabID);
							} else {
								contentGrid.getStore().removeAll();
								if (result.dayItemList != null) {
									contentGrid.getStore().loadData(
											result.dayItemList);
								}
							}
						} else {
							top.Ext.MessageBox.alert(Constant.PROMPT,
									result.error, function() {
									});
						}
					},
					failure : ajaxFailureHandler
				});

	}