<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<%@ include file="/jsp/core/tag-core.jsp"%>
<%@ include file="/jsp/core/tag-extjs4.2.jsp"%>
<link rel="stylesheet" type="text/css" href="<%=path%>/framework/css/page.css">
<script type="text/javascript" src="<%=path%>/framework/extjs4.2/ux/TreePicker.js"></script>
<script type="text/javascript" src="<%=path%>/framework/extjs4.2/ux/form/MultiSelect.js"></script>
<script type="text/javascript" src="<%=path%>/framework/extjs4.2/ux/form/ItemSelector.js"></script>
</head>
<body>
	<script type="text/javascript">
		var mmsForm, mmsWin, layout_panel, currentid, mmssonForm, mmssonwin;

		/* - 定义一线支撑用户显示组件 - */
		Ext.define("Mms", {
			extend : "Ext.data.Model",
			idProperty : "id",
			fields : [ {
				name : "id",
				type : "string"
			}, {
				name : "repName",
				type : "string"
			}, {
				name : "repHeadSql",
				type : "string"
			}, {
				name : "repDateSql",
				type : "string"
			}, {
				name : "repGoinSql",
				type : "string"
			}, {
				name : "repDesc",
				type : "string"
			}, {
				name : "repPos",
				type : "string"
			}, {
				name : "repIsChart",
				type : "string"
			}, {
				name : "repChartSql",
				type : "string"
			}, {
				name : "dataSourceId",
				type : "string"
			}, {
				name : "repSql",
				type : "string"
			} ]
		});
		/* - 定义数据源 - */
		var mms_grid_store = Ext.create("Ext.data.Store", {
			model : "Mms",
			proxy : {
				type : "ajax",
				actionMethods : "post",
				url : "MmsWeb.do?getGridStore",
				reader : {
					type : "json",
					root : "root",
					totalProperty : "total"
				}
			},
			pageSize : 15
		});
		mms_grid_store.on("beforeload", function(store, options) {
			//var search_type = Ext.getCmp("search_type").value;
			var search_name = Ext.getCmp("search_name").value;
			var params = {/* search_type: search_type, */
				search_name : search_name
			};
			Ext.apply(store.proxy.extraParams, params);
		});

		/* - 定义页面组件 - */
		var mms_grid = Ext.create("Ext.grid.Panel", {
			store : mms_grid_store,
			selType : "checkboxmodel",
			region : "west",
			title : "彩信列表",
			store : mms_grid_store,
			collapsible : false,
			split : true,
			forceFit : true,
			border : false,
			loadMask : true,
			stripeRows : true,
			width : "65%",
			tbar : [ "-",
			/* {xtype: "textfield", id: "search_type", width: 120, emptyText: "报表编码",
				listeners:{specialkey:function(f, e){if(e.getKey() == e.ENTER)search();}}
			}, */
			{
				xtype : "textfield",
				id : "search_name",
				width : 200,
				emptyText : "报表名称",
				listeners : {
					specialkey : function(f, e) {
						if (e.getKey() == e.ENTER)
							search();
					}
				}
			}, "-", {
				text : "查询",
				iconCls : "search",
				handler : search
			}, {
				text : "重置",
				iconCls : "refresh",
				handler : reset
			}

			],
			columns : [

			{
				menuDisabled : true,
				sortable : false,
				align : "center",
				width : 1,
				dataIndex : "repName",
				header : "报表名称",
				renderer : function(value, cellmeta, record, rowIndex, columnIndex, stroe) {
					return "<a href=javascript:updateMms('" + rowIndex + "');>" + record.raw.repName + "</a>";
				}
			},

			{
				menuDisabled : true,
				sortable : false,
				align : "center",
				width : 1,
				dataIndex : "repPos",
				header : "报表排序",
			},

			{
				menuDisabled : true,
				sortable : false,
				align : "center",
				width : 1,
				dataIndex : "dataSourceId",
				header : "数据源标示",
			},

			{
				menuDisabled : true,
				sortable : false,
				align : "center",
				width : 1,
				dataIndex : "repGoinSql",
				header : "是否下钻",
				renderer : function(v, cellValues, rec) {
					return rec.data.repGoinSql == "select 0 from dual" ? "<span style='color:red'>否</span>" : "<span style='color:green'>是</span>";

				}
			},

			/* {menuDisabled: true, sortable: false, align: "center", width: 1, dataIndex: "repIsChart",      header: "是否显示趋势图",
				renderer: function(v, cellValues, rec) {
			 	   return rec.data.repIsChart == "0" ? "<span style='color:red'>否</span>":"<span style='color:green'>是</span>";
			    }
			},  */

			{
				menuDisabled : true,
				sortable : false,
				align : "center",
				width : 1,
				dataIndex : "repDesc",
				header : "报表描述",
			}, ],

			listeners : {
				itemclick : function(me, record, item, index, e, eOpts) {
					currentid = record.raw.id;
					//alert(currentid);
					mmsson_grid_store.load({
						params : {
							pageId : currentid
						}
					});
				}
			},

			bbar : Ext.create("Ext.PagingToolbar", {
				store : mms_grid_store,
				displayInfo : true,
				displayMsg : "显 示 {0} - {1} 条 , 共 计 {2} 条",
				emptyMsg : "没 有 数 据",
				items : [ {
					text : "添加服务",
					iconCls : "add",
					handler : addMms
				}, {
					text : "删除服务",
					iconCls : "delete",
					handler : deleteMms
				} ]
			})
		});
		/* - 初始化页面 - */
		/* Ext.onReady(function() {
		 Ext.tip.QuickTipManager.init();
		 Ext.create("Ext.Viewport", {layout: "fit", padding: 0, items: mms_grid});
		 reset();
		 }); */
		/* - 查询 - */
		function search() {

			mms_grid_store.load();
		}
		/* - 重置 - */
		function reset() {
			//Ext.getCmp("search_type").setValue("");
			Ext.getCmp("search_name").setValue("");
			//searchSon();
			search();

		}

		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/* /* - 定义已分配角色菜单面板相关组件 - */
		Ext.define("MmsSon", {
			extend : "Ext.data.Model",
			idProperty : "id",
			fields : [ {
				name : "id",
				type : "string"
			}, {
				name : "headName",
				type : "string"
			}, {
				name : "headPos",
				type : "string"
			}, {
				name : "headSts",
				type : "string"
			}, {
				name : "repId",
				type : "string"
			} ]
		});
		mmsson_grid_store = Ext.create("Ext.data.Store", {
			model : "MmsSon",
			proxy : {
				type : "ajax",
				actionMethods : "post",
				url : "MmsSonWeb.do?getGridStore",
				reader : {
					type : "json",
					root : "root",
					totalProperty : "total"
				}
			},
			pageSize : 15
		});

		mmsson_grid = Ext.create("Ext.grid.Panel", {
			region : "center",
			title : "表头信息",
			store : mmsson_grid_store,
			selType : "checkboxmodel",
			forceFit : true,
			border : false,
			loadMask : true,
			stripeRows : true,

			tbar : [ "-", {
				text : "添加",
				iconCls : "add",
				handler : addMmsson
			}, {
				text : "删除",
				iconCls : "delete",
				handler : deleteMmsson
			}, "-" ],

			columns : [ {
				header : "表头名称",
				width : 3,
				dataIndex : "headName",
				menuDisabled : true,
				align : "center",
				renderer : function(value, cellmeta, record, rowIndex, columnIndex, stroe) {
					return "<a href=javascript:updateMmsSon('" + rowIndex + "');>" + record.raw.headName + "</a>";
				}
			},

			//{header: "表头名称", width: 3, dataIndex: "headName", menuDisabled: true, sortable: false, align: "center"},
			{
				header : "表头排序",
				width : 3,
				dataIndex : "headPos",
				menuDisabled : true,
				sortable : false,
				align : "center"
			}, {
				header : "表头状态位",
				width : 3,
				dataIndex : "headSts",
				menuDisabled : true,
				sortable : false,
				align : "center"
			}, ],

		});

		/*-管理页面布局-*/
		layout_panel = Ext.create("Ext.Panel", {
			border : false,
			layout : "border",
			items : [ mmsson_grid, mms_grid ]
		});
		Ext.onReady(function() {
			Ext.tip.QuickTipManager.init();
			Ext.create("Ext.Viewport", {
				layout : "fit",
				padding : 0,
				items : layout_panel
			});
			reset();

		});

		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/* - 创建服务信息面板 - */
		function createmmsForm() {
			mmsForm = Ext.create("Ext.form.Panel", {
				bodyPadding : "10 30 10 30",
				border : false,
				bodyStyle : 'overflow-x:hidden; overflow-y:scroll',
				fieldDefaults : {
					labelWidth : 100,
					msgTarge : "side",
					allowBlank : false,
					autoFitErrors : false
				},
				defaultType : "textfield",
				defaults : {
					width : 700
				},
				height : 450,
				fieldDefaults : {
					labelWidth : 100,
					labelAlign : "left",
					flex : 1,
					margin : 5
				},
				items : [ {
					hidden : true,
					allowBlank : true,
					name : "id"
				},

				{
					xtype : "container",
					layout : "hbox",
					items : [ {
						xtype : "textfield",
						name : "repName",
						fieldLabel : "报表名称",
						decimalPrecision : 0,
					} ]
				},

				{
					xtype : "container",
					layout : "hbox",
					items : [ {
						xtype : "textfield",
						name : "dataSourceId",
						fieldLabel : "数据源标示",
						allowBlank : false,
						value : "ORA1"
					},
					/* {
										xtype : "numberfield",
										name : "repPos",
										fieldLabel : "报表排序",
										decimalPrecision : 0,
										maskRe : /\d/
									} */

					{
						xtype : "container",
						fieldLabel : "报表排序",
						name : "repPos",
						displayField : "text",
						minPickerHeight : 240,
						maxPickerHeight : 240,
						rootVisible : true
					},

					]

				},

				{
					xtype : "combobox",
					fieldLabel : "是否下钻",
					name : "repGoinSql",
					mode : "remote",
					valueField : "id",
					displayField : "name",
					editable : false,
					emptyText : '--请选择--',
					store : new Ext.data.Store({
						proxy : {
							type : "ajax",
							actionMethods : "post",
							url : "MmsWeb.do?getTypeComboBox",
							reader : {
								type : "json",
								root : "root",
								totalProperty : "total"
							}
						},
						fields : [ "id", "name" ],
						autoLoad : true
					}),
					listeners : {
						change : function(field, newValue, oldValue) {
							//console.log("---------" + field);
							//console.log("---------" + newValue);
							//console.log("---------" + oldValue);
							mmsForm.form.findField("rep").setValue(newValue);
						}
					}

				},

				{
					fieldLabel : "    ",
					name : "rep",
					xtype : "textareafield",
					allowBlank : true,

				},

				/* {xtype: "combobox", fieldLabel: "是否显示趋势图", name: "repIsChart",
					mode: "remote", valueField: "id", displayField: "name", editable: false,emptyText: '--请选择--',
					store: new Ext.data.Store({
					    proxy: {type: "ajax", actionMethods: "post",
					    	url: "MmsWeb.do?getIsSellTypeList",
							reader: {type: "json", root: "root", totalProperty: "total"}
						}, fields: ["id", "name"], autoLoad: true
					})
				}, */

				//{fieldLabel: "报表数据日期SQL", name: "repDateSql",},
				{
					xtype : "combobox",
					fieldLabel : "报表数据日期SQL",
					name : "repDateSql",
					mode : "remote",
					valueField : "id",
					displayField : "name",
					editable : false,
					emptyText : '--请选择--',
					store : new Ext.data.Store({
						proxy : {
							type : "ajax",
							actionMethods : "post",
							url : "MmsWeb.do?getTypeData",
							reader : {
								type : "json",
								root : "root",
								totalProperty : "total"
							}
						},
						fields : [ "id", "name" ],
						autoLoad : true
					}),

					listeners : {
						change : function(field, newValue, oldValue) {
							//console.log("---------" + field);
							//console.log("---------" + newValue);
							//console.log("---------" + oldValue);\
							mmsForm.form.findField("tem").setValue(newValue);
							//Ext.get("repHeadSql").setValue(newValue);
						}
					}

				},

				{
					fieldLabel : "    ",
					name : "tem",
					xtype : "textareafield",
					allowBlank : true,

				},

				/* {
					fieldLabel : "报表描述",
					name : "repDesc",
					xtype : "textareafield",
					allowBlank : true,
					height : 40,
					height : 50,
				}, */

				{
					fieldLabel : "报表头SQL",
					name : "repHeadSql",
					xtype : "textareafield",
					allowBlank : true,
					height : 70,
					value : "select head_name from t2_rep_head  where rep_id = '$rep_id$' order by head_pos",
					hidden : true,
				},

				//{fieldLabel: "趋势图语句", name: "repChartSql", xtype: "textareafield", allowBlank: true,height: 70}, 			
				{
					fieldLabel : "报表SQL",
					name : "repSql",
					xtype : "textareafield",
					allowBlank : true,
					height : 150
				}

				]
			});
		}

		/* - 添加服务 - */
		function addMms() {
			createmmsForm();
			//mmsForm.getForm().findField("repGoinSql").setValue(0);
			//mmsForm.getForm().findField("repIsChart").setValue(0);
			mmsWin = Ext.create("Ext.window.Window", {
				title : "添加服务",
				layout : "fit",
				closeAction : "close",
				items : mmsForm,
				border : false,
				autoShow : true,
				constrain : true,
				resizable : false,
				modal : true,
				buttons : [ {
					text : "保存",
					handler : function() {

						mmsForm.getForm().submit({
							url : "MmsWeb.do?addMms",
							success : function(form, action) {
								mms_grid_store.reload();
								mmsWin.close();
								Ext.MessageBox.alert("成功", "添加成功！");
							},
							failure : function(form, action) {
								mmsWin.close();
								Ext.MessageBox.alert("失败", "后台发生错误！请重试！");
							}
						});
					}
				} ]
			});
		}
		/* - 修改服务 - */
		function updateMms(rowIndex) {
			var currentMms = mms_grid_store.getAt(rowIndex);
			createmmsForm();
			mmsForm.loadRecord(currentMms);
			//mmsForm.getForm().findField("repGoinSql").setValue(currentMms.raw.repGoinSql);
			//mmsForm.getForm().findField("repIsChart").setValue(currentMms.raw.repIsChart);

			mmsWin = Ext.create("Ext.window.Window", {
				title : "修改 '" + currentMms.raw.repName + "'服务",
				layout : "fit",
				closeAction : "close",
				items : mmsForm,
				border : false,
				autoShow : true,
				constrain : true,
				resizable : false,
				modal : true,
				buttons : [ {
					text : "保存",
					handler : function() {
						mmsForm.getForm().submit({
							url : "MmsWeb.do?updateMms",
							success : function(form, action) {
								mms_grid_store.reload();
								mmsWin.close();
								Ext.MessageBox.alert("成功", "修改成功！");
							},
							failure : function(form, action) {
								mmsWin.close();
								Ext.MessageBox.alert("失败", "后台发生错误！请重试！");
							}
						});
					}
				} ]
			});
		}
		/* - 删除服务 - */
		function deleteMms() {
			var mmss = mms_grid.getSelectionModel().getSelection(), title, mmsid = "";
			if (mmss.length == 0) {
				Ext.MessageBox.alert("提示", "请选择需要删除的服务！");
			} else {
				title = "确定要删除这" + mmss.length + "个服务吗?";
				for (var i = 0; i < mmss.length; i++)
					mmsid += ",'" + mmss[i].data.id + "'";
				Ext.MessageBox.confirm("提示", title, function(btn) {
					if (btn == "yes") {
						Ext.Ajax.request({
							method : "post",
							url : "MmsWeb.do?deleteMms",
							params : {
								mmsid : mmsid.substring(1)
							},
							success : function(response) {
								var result = Ext.decode(response.responseText);
								if (result.success == false)
									Ext.MessageBox.alert("提示", result.errors);
								else {
									mms_grid_store.load();
									Ext.MessageBox.alert("成功", "删除成功！");
								}
							}
						});
					}
				});
			}
		}

		//------------------------------------------------------------------------------------------------

		function createmmssonForm() {
			mmssonForm = Ext.create("Ext.form.Panel", {
				bodyPadding : "10 30 10 30",
				border : false,
				bodyStyle : 'overflow-x:hidden; overflow-y:scroll',
				fieldDefaults : {
					labelWidth : 100,
					msgTarget : "side",
					allowBlank : false,
					autoFitErrors : false
				},
				defaultType : "textfield",
				defaults : {
					width : 500
				},
				height : 300,
				fieldDefaults : {
					labelWidth : 100,
					labelAlign : "left",
					flex : 0,
					margin : 2
				},
				items : [ {
					hidden : true,
					allowBlank : true,
					name : "id"
				}, {
					hidden : true,
					allowBlank : true,
					name : "repId",
					id : "repId",
					xtype : "hiddenfield"
				}, {
					fieldLabel : "表头名称",
					name : "headName",
				}, {
					fieldLabel : "表头排序",
					name : "headPos",
				}, {
					fieldLabel : "表头状态",
					name : "headSts",
				},

				]
			});
		}

		/* - 添加服务 - */
		function addMmsson() {
			createmmssonForm();
			mmssonwin = Ext.create("Ext.window.Window", {
				title : "添加服务",
				layout : "fit",
				closeAction : "close",
				items : mmssonForm,
				border : false,
				autoShow : true,
				constrain : true,
				resizable : false,
				modal : true,
				buttons : [ {
					text : "保存",
					handler : function() {
						/////////
						Ext.getCmp("repId").setValue(currentid);
						mmssonForm.getForm().submit({
							url : "MmsSonWeb.do?addMmsSon",
							success : function(form, action) {
								mmsson_grid_store.reload();
								mmssonwin.close();
								Ext.MessageBox.alert("成功", "添加成功！");
							},
							failure : function(form, action) {
								mmssonwin.close();
								Ext.MessageBox.alert("失败", "后台发生错误！请重试！");
							}
						});
					}
				} ]
			});
		}

		/* - 修改服务 - */
		function updateMmsSon(updateid) {
			var currentMmsson = mmsson_grid_store.getAt(updateid);
			createmmssonForm();
			mmssonForm.loadRecord(currentMmsson);
			//mmssonForm.getForm().findField("repGoinSql").setValue(currentMmsson.raw.repGoinSql);
			//mmssonForm.getForm().findField("repIsChart").setValue(currentMmsson.raw.repIsChart);

			mmssonwin = Ext.create("Ext.window.Window", {
				title : "修改 '" + currentMmsson.raw.headName + "' 服务",
				layout : "fit",
				closeAction : "close",
				items : mmssonForm,
				border : false,
				autoShow : true,
				constrain : true,
				resizable : false,
				modal : true,
				buttons : [ {
					text : "保存",
					handler : function() {
						mmssonForm.getForm().submit({
							url : "MmsSonWeb.do?updateMmsSon",
							success : function(form, action) {
								mmsson_grid_store.reload();
								mmssonwin.close();
								Ext.MessageBox.alert("成功", "修改成功！");
							},
							failure : function(form, action) {
								mmssonwin.close();
								Ext.MessageBox.alert("失败", "后台发生错误！请重试！");
							}
						});
					}
				} ]
			});
		}

		/* - 删除服务 - */
		function deleteMmsson() {

			var mmss = mmsson_grid.getSelectionModel().getSelection(), title, mmsid = "";
			if (mmss.length == 0) {
				Ext.MessageBox.alert("提示", "请选择需要删除的服务！");
			} else {
				title = "确定要删除这" + mmss.length + "个服务吗?";
				for (var i = 0; i < mmss.length; i++)
					mmsid += ",'" + mmss[i].data.id + "'";
				Ext.MessageBox.confirm("提示", title, function(btn) {
					if (btn == "yes") {
						Ext.Ajax.request({
							method : "post",
							url : "MmsSonWeb.do?deleteMmsSon",
							params : {
								mmsid : mmsid.substring(1)
							},
							success : function(response) {
								var result = Ext.decode(response.responseText);
								if (result.success == false)
									Ext.MessageBox.alert("提示", result.errors);
								else {
									mmsson_grid_store.reload();
									Ext.MessageBox.alert("成功", "删除成功！");
								}
							}
						});
					}
				});
			}
		}
	</script>
</body>
</html>