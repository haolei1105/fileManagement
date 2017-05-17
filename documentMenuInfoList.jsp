<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page
	import="org.apache.shiro.web.filter.authc.FormAuthenticationFilter"%>
<%@ include file="/WEB-INF/views/include/taglib.jsp"%>
<html>
<head>
    <meta name="decorator" content="blank" />
    <title>文件管理模块</title>
    <link type="text/css" rel="stylesheet" href="${ctxStatic}/myhao/css/reset.min.css"/>
    <link type="text/css" rel="stylesheet" href="${ctxStatic}/myhao/css/index.css"/>
    <script charset="UTF-8" type="text/javascript" src="${ctxStatic}/myhao/js/jquery1.7.2.js"></script>
    <script charset="UTF-8" type="text/javascript" src="${ctxStatic}/myhao/js/jquery.contextmenu.r2.js"></script>
    <script charset="UTF-8" type="text/javascript" src="${ctxStatic}/myhao/js/ajaxfileupload.js"></script>
	<script charset="UTF-8" type="text/javascript" src="${ctxStatic}/myhao/js/jquery.form.js"></script>
 	<style>
		#box #food #file .defaultWindow div {
          padding: 250px 165px 10px 140px;
          width: 488px;
          background: url(${ctxStatic}/myhao/images/start.png) no-repeat center center;
}
	</style>
	<script>
	$(document).ready(function() {
		/*点击部门初始页消失  */
		statrWin();
		function statrWin(){
			/*点击某个部门文件部分首页消失，部门文件显示*/
			 $(".subNav").click(function(){
					var startVal=$(this).children().val();//获取部门下隐藏域的input的value值，确定点击的是哪个部门。
					 $.ajax({
			                url:'/jrjw/a/documentmenu/documentMenuInfo/brunchFile',
			                data:{
			                	id:startVal
			                },
			                success:function(aa){
			                	$("#brunchFiles").children().remove();//返回成功删除该文件窗口下的所有文件夹；
								if(aa.limitedList && aa.limitedList.length>0){
									for (var i = 0; i <aa.limitedList.length; i++) {
										var div="<li class='db_folder'>"+
											"<input type='hidden' value='"+aa.limitedList[i].id+"'/>"+
				                            "<img src='${ctxStatic}/images/file.png' alt=''/>"+
				                            "<p>"+aa.limitedList[i].name+"</p>"+
				                       "</li>";
				                       $("#brunchFiles").append(div);//创建新的文件夹；
									}
									
									/*单机文件夹背景色变化  */
									$(".db_folder").each(function(){//循环每个文件夹
								        $(this).toggle(function(){
							                $(this).css("border-color","#008000");//点击文件夹该文件件夹边框颜色切换
							            	console.log($(this).css("border-color"));    
								        },
							            function(){
							                $(this).css("border-color","#fdfefe");}
							        );
									});
									/*右键删除文件夹*/
									$('.db_folder').contextMenu('myMenu2', {//文件夹右击事件
		            					bindings: {
		            						'delete_folder': function (t) {
		            		                	var msg = "您真的确定要该文件夹吗？";
		            		                	if(confirm(msg)==true){//点击确定执行里面的代码
		            		                		console.log(startVal);//部门ID
		            		                	var delete_folderId=$(t).children("input").val();
		            		                		console.log(delete_folderId);//删除的文件夹ID

		            			                	 $.ajax({
		            			     	                url:'',
		            			     	                data:{
		            			     	                	departmentId:startVal,
		            			     	                	folderId:delete_folderId
		            			     	                },
		            			     	               success: function (aa) {
		            			  							alert("删除成功");
		            			   	                    	window.location.reload();
		            			   	                }
		            			     			 }); 
		            		                    }else{
		            		                        return false;
		            		                    }
		            						}
		           						 }
									});
								
									/*双击文件夹，进入该文件内  */
									 $(".db_folder").children("img").each(function(index,item){//循环文件夹 图片
										 $(this).dblclick(function(){//双击该文件夹图片
											 var folderId = $(this).parent().children().first().val();//变量保存文件夹下的隐藏域的value（ID）值；
											 $.ajax({
									                url:'/jrjw/a/documentmenu/documentMenuInfo/brunchFile',
									                cache:false, 
									                data:{
									                	id:folderId
									                },
									                success :function(aa){
									                	
									                	if(aa.limitedList && aa.limitedList.length>0){
									                		$("#folder_win").css({"display": "none", "z-index": 0});
									    		            $("#file_win").css({"display": "block", "z-index": 10});//具体文件窗口展示
										                	$(".top2_next_ul").css("display", "block");
										                	$("#thirdLevel").children().remove();//具体文件窗口下的内容清空
									                		for (var i = 0; i <aa.limitedList.length; i++) {
									                			var div="<li class='db_file'>"+
									                			"<input type='hidden' value='"+aa.limitedList[i].id+"'/>"+
								                            	"<img src='${ctxStatic}/images/dbfile.png' alt=''/>"+
								                            	"<p>"+aa.limitedList[i].name+"</p>"+
								                            	"</li>";
								                            	$("#thirdLevel").append(div);//后台获取插入新的文件内容，插入到具体文件窗口
									                		}
									                		 /*右键删除文件  */
									                		 yy();
									                		function yy(){
																console.log($('.db_file'))
																$('.db_file').contextMenu('myMenu3', {
									            					bindings: {
									            						'delete_file': function (t) {//右键文件选择删除文件
									            		                	var msg = "您真的确定要该文件吗？";
									            		                	if(confirm(msg)==true){
									            		                		var delete_fileId=$(t).children("input").val();
									            		                		console.log(folderId);
									            		                		console.log(delete_fileId);
									            			                	$.ajax({
									            			     	                url:'',
									            			     	                data:{
									            			     	                	id:folderId,//文件的父级文件夹ID
									            			     	                	delete_fileId:delete_fileId//将要删除的文件ID
									            			     	                },
									            			     	               success: function (aa) {
									            			   	                    	window.location.reload();
									            			   	                }
									            			     			 });
									            		                    }else{
									            		                        return false;
									            		                    }
									            						},
									            						'download':function (t) {//右键文件选择下载文件
									            							var msg = "您确定下载该文件吗？";
									            		                	if(confirm(msg)==true){
									            		                		var detele_fileName=$(t).children("p").text();
									            		                		var filename=detele_fileName.replace(/.*(\/|\\)/, ""); 
									            		                		var fileExt=(/[.]/.exec(filename)) ? /[^.]+$/.exec(filename.toLowerCase()) : '';
									            		                		alert(fileExt);
									            			                	$.ajax({
									            			     	                url:'',
									            			     	                data:{
									            			     	                	detele_fileName:detele_fileName,//文件的名称
									            			     	                	fileExt:fileExt//文件的名称
									            			     	                },
									            			     	               success: function (aa) {
									            			   	                    	alert("下载成功")
									            			   	                }
									            			     			 });
									            						}else{
									            							return false;
									            							}
									            						}
									           						 }
																}); 
									                		 }
								                        
									                	}else{
									                		$("#folder_win").css({"display": "none", "z-index": 0});
									    		            $("#file_win").css({"display": "block", "z-index": 10});
										                	$(".top2_next_ul").css("display", "block");
										                	$("#thirdLevel").children().remove();
									                	}
									                }
											 });
											 
											
											 /*文件上传*/
									         $("#add_files").click(function(){//点击表头上传按钮，跳转到上传界面；
										         $(".defaultWindow").css({"display": "none", "z-index": 0});
										         $("#folder_win").css({"display": "none", "z-index": 0});
										         $("#file_win").css({"display": "none", "z-index": 0});
										         $("#scWin").css({"display": "block", "z-index": 10});
										         });
										     $("#winBack").click(function(){//点击返回按钮，返回到具体文件页面；
										         $(".defaultWindow").css({"display": "none", "z-index": 0});
										         $("#folder_win").css({"display": "none", "z-index": 0});
										         $("#file_win").css({"display": "block", "z-index": 10});
										         $("#scWin").css({"display": "none", "z-index": 0});
										         });
										     
											 $("#btnsubmit").click(function(){//点击确认上传按钮
													var uploadForm=$("#uploadForm");
												    uploadForm.children().first().val(folderId);//设置该文件所在文件夹的ID值保存到form表单的隐藏域的value值中；
												    var tt=uploadForm.children().first().val();
												    console.log(tt);
												    $.ajaxFileUpload({
												    	 url: "/jrjw/a/documentmenu/documentMenuInfo/upload?id="+tt,//用于文件上传的服务器端请求地址
													     secureuri: false,//一般设置为false
													     fileElementId :'fileId',//file控件的id
													     dataType: 'json',
													     complete:function(data){//只要完成即执行，最后执行
													        },
													     error: function() { alert('加载错误！！！'); },//服务器响应失败处理函数
													     success: function(data) {//服务器成功响应处理函数
													         if(data.resultFlag=='yes'){
													        	//$.jBox.info("上传成功！");
													        	alert("上传成功！");
													         }else if(data.resultFlag=='no'){
													        	//$.jBox.info("文件为空！");
													        	alert("文件为空！");
													         }else if(data.resultFlag=='no'){
													        	//$.jBox.info("上传失败！");
													        	alert("上传失败！");
													         }
													     }
												    });
												});
											
										 });
									 });
								}
			             }
					 });
		            $(".defaultWindow").css({"display": "none", "z-index": 0});
		            $("#folder_win").css({"display": "block", "z-index": 10});
		            $("#file_win").css({"display": "none", "z-index": 0});
		            $("#scWin").css({"display": "none", "z-index": 0});
		            $("#sharewin").css({"display": "none", "z-index": 0});
		         });
		};
		    /*文件夹分享  */
		    fx();
		    function fx(){
		    	/*分享那个文件夹*/
		    	var wjjId="";
				 $("#new_folder").click(function(){
			    	 $(".db_folder").each(function(){//判断文件夹点击选中，IE不识别rgb
 						 if($(this).css("border-color")=="rgb(0, 128, 0)"||$(this).css("border-color")=="#008000"){
							 wjjId+=$(this).children().first().val();//变量拼接该文件夹的ID值
								 wjjId+=",";//拼接逗号
						 }
					 });
					 if(wjjId!=""){//确认有文件夹被选中，变量的内容不为空
						 console.log("1");
						 $(".defaultWindow").css({"display": "none", "z-index": 0});
				         $("#folder_win").css({"display": "none", "z-index": 0});
				         $("#file_win").css({"display": "none", "z-index": 0});
				         $("#scWin").css({"display": "none", "z-index": 0});
				         $("#sharewin").css({"display": "block", "z-index": 10});//跳转到分享界面
					 }else{
						 alert("分享文件夹不能为空");
					 }
				 });
				 /*确定分享给哪个部门  */
				 $("#count").click(function(){
					 console.log("2");
					 var newwjjId=wjjId.substring(0,wjjId.length-1);//去掉变量的字符串最后一个逗号，并保存到新的变量中；
					 var searchId="";
					 $(".btnture").each(function(){
						 if($(this).prop("checked")==true){//如果分享部门前复选框被选中；
							 searchId+=$(this).prevAll("input").first().val();//获取该部门的下第一个隐藏域的ID值；
							 searchId+=",";//给变量拼接逗号；
						 }
					 });
					 var newsearchId=searchId.substring(0,searchId.length-1);//去除变量的最后一个逗号，并且保存到新的变量里；
					 console.log(newwjjId);
					 console.log(newsearchId);
					 if(searchId!=""&&wjjId!=""){
						 $.ajax({
				                url:'/jrjw/a/documentmenu/documentMenuInfo/shareFiles',
				                data:{
				                	folderId:encodeURI(newwjjId),//文件夹的ID
									departmentId:encodeURI(newsearchId)//传递部门的ID
				                },
				                success: function (returndata) {
						 		     $(".defaultWindow").css({"display": "none", "z-index": 0});
							         $("#folder_win").css({"display": "block", "z-index": 10});//分享成功之后返回到具体文件夹界面；
							         $("#file_win").css({"display": "none", "z-index": 0});
							         $("#scWin").css({"display": "none", "z-index": 0});
							         $("#sharewin").css({"display": "none", "z-index": 0});
							        wjjId="";//将变量清空
				                	$(".folder_xz").each(function(){
				                        $(this).attr('checked',false);
				                	});
				                	$(".btnture").each(function(){
				                        $(this).attr('checked',false);
				                	});
						        }
						 }); 
					 }else{
						 alert("分享部门不能为空");
					 }
					 })
				 
			     $("#chareBack").click(function(){
				        wjjId="";
	                	$(".folder_xz").each(function(){
	                        $(this).attr('checked',false);
	                	});
	                	$(".btnture").each(function(){
	                        $(this).attr('checked',false);
	                	});
			         $(".defaultWindow").css({"display": "none", "z-index": 0});
			         $("#folder_win").css({"display": "block", "z-index": 10});
			         $("#file_win").css({"display": "none", "z-index": 0});
			         $("#scWin").css({"display": "none", "z-index": 0});
			         $("#sharewin").css({"display": "none", "z-index": 0});
			         });
				 
				 
				 $(".subNav").each(function(index,tiem){
					 var bmName=$(this).text();
					 var oliId=$(this).children().first().val();
					 var olis=document.createElement("li");
 					 var oInputs=document.createElement("input");
			         $(oInputs).attr({
			                "type":"checkbox",
			                "name": "test",
			                "class":"btnture"
			             });
			         var oUl=$(".shareWindow_ul");
			         var oInputId=document.createElement("input");
			         $(oInputId).attr(
			        	 "type","hidden"
			         )
			         $(oInputId).val(oliId);
			         $(olis).append(oInputId);
			         $(olis).append(oInputs);
			         $(olis).append(bmName);
			         oUl.append(olis);
				 });
		    }
		    
		    
		    /*所搜 功能 */
		    searchInput();
		    function searchInput(){
		    	 var curSearch = $("#search_input");
				    curSearch.focus(function () {
				        if ($(this).val() != "") {
				            $(this).val("");
				        }
				    });
					
/* 				    curSearch.blur(function(){
				    	 $(this).val("文件搜索")
				    }) */
				    curSearch.keyup(function(e) {  
				       if(e.keyCode  == 13 && $(this).val()!=""&&$(this).val()!="文件搜索") {  
				    	   var valueSearch=$(this).val();
 				    	   $.ajax({
	        	                url:'/jrjw/a/documentmenu/documentMenuInfo/searchFiles',
	        	                data:{
									name:encodeURI(valueSearch)
	        	                },
	        	                success :function(aa){
	        	                	curSearch.val("文件搜索");
	        				         $(".defaultWindow").css({"display": "none", "z-index": 0});
	        				         $("#folder_win").css({"display": "none", "z-index": 0});
	        				         $("#file_win").css({"display": "block", "z-index": 10});
	        				         $("#scWin").css({"display": "none", "z-index": 0});
	        				         $("#sharewin").css({"display": "none", "z-index": 0});
	        				         $("#thirdLevel").children().remove();
	        				         alert("result="+aa.result);
	 								if(aa.result && aa.result.length>0){
	 									for (var i = 0; i <aa.result.length; i++) {
				                			var div="<li class='db_file'>"+
				                			"<input type='hidden' value='1'/>"+
			                            	"<img src='${ctxStatic}/images/dbfile.png' alt=''/>"+
			                            	"<p>"+aa.result[i].name+"</p>"+
			                            	"</li>";
			                            	$("#thirdLevel").append(div);
				                		}
	 									/*搜索成功之后对文件操作*/
	 									$(".db_file").each(function(){
											console.log($('.db_file').children("input").val())
											$(this).contextMenu('myMenu3', {
												bindings: {
				            						'delete_file': function (t) {//右键文件选择删除文件
				            		                	var msg = "您真的确定要该文件吗？";
				            		                	if(confirm(msg)==true){
				            		                		var delete_fileId=$(t).children("input").val();
				            			                	$.ajax({
				            			     	                url:'',
				            			     	                data:{
				            			     	                	delete_fileId:delete_fileId//将要删除的文件ID
				            			     	                },
				            			     	               success: function (aa) {
				            			   	                    	/* window.location.reload(); */
				            			   	                }
				            			     			 });
				            		                    }else{
				            		                        return false;
				            		                    }
				            						},
				            						'download':function (t) {//右键文件选择下载文件
				            							var msg = "您确定下载该文件吗？";
				            		                	if(confirm(msg)==true){
				            		                		var detele_fileName=$(t).children("p").text();
				            		                		var filename=detele_fileName.replace(/.*(\/|\\)/, ""); 
				            		                		var fileExt=(/[.]/.exec(filename)) ? /[^.]+$/.exec(filename.toLowerCase()) : '';
				            		                		alert(fileExt);
				            			                	$.ajax({
				            			     	                url:'',
				            			     	                data:{
				            			     	                	detele_fileName:detele_fileName,//文件的名称
				            			     	                	fileExt:fileExt//文件的名称
				            			     	                },
				            			     	               success: function (aa) {
				            			   	                    	alert("下载成功")
				            			   	                }
				            			     			 });
				            						}else{
				            							return false;
				            							}
				            						}
				           						 }
											}); 
	 									})
	 								}else{
	 									alert("您所查找的文件不存在");
	 								}
	        				         
	        	                },
	        	                error:function(){
	        	                	alert("系统内部出错，请联系管理员");
	        	                }
	                    	});
				       }     
				       });
				    $("#seachEnter").click(function(){
				    	if(curSearch.val()!=""&&curSearch.val()!="文件搜索"){
				    		var valueSearch=curSearch.val();
				    		console.log(valueSearch)
				    		  $.ajax({
		        	                url:'/jrjw/a/documentmenu/documentMenuInfo/searchFiles',
		        	                data:{
										name:encodeURI(valueSearch)		
		        	                },
		        	                success :function(aa){
		        	                	$(curSearch).val("文件搜索");
		        				         $(".defaultWindow").css({"display": "none", "z-index": 0});
		        				         $("#folder_win").css({"display": "none", "z-index": 0});
		        				         $("#file_win").css({"display": "block", "z-index": 0});
		        				         $("#scWin").css({"display": "none", "z-index": 0});
		        				         $("#sharewin").css({"display": "none", "z-index": 0});
		        				         $("#thirdLevel").children().remove();
		        				         alert("result="+aa.result);
		 								if(aa.result && aa.result.length>0){
		 									for (var i = 0; i <aa.result.length; i++) {
					                			var div="<li class='db_file'>"+
				                            	"<img src='${ctxStatic}/images/dbfile.png' alt=''/>"+
				                            	"<p>"+aa.result[i].name+"</p>"+
				                            	"</li>";
				                            	$("#thirdLevel").append(div);
					                		}

		 								}else{
		 									alert("您所查找的文件不存在");
		 								}
		        	                },
		        	                error:function(){
		        	                	alert("系统内部出错，请联系管理员");
		        	                }
		                    	});
					       }     
					       });
				    	}
		    
		    /* 添加部门 */
		    addDepartment();
			function addDepartment(){
				$("#add_menu").click(function () {
				    var isChrome = window.navigator.userAgent.indexOf("Chrome") !== -1;
				    if (isChrome) {
				        alert("是Chrome浏览器");
				        var msg = "您真的确定修添加新部门吗？";
		            	if(confirm(msg)==true){
		            		 $("#add_input").css("display", "block");
					            var bm_name = $("#bm_name");
					            bm_name.val("输入名称");
					            bm_name.focus();
					            bm_name.click(function () {
					                if ($(this).val() != "") {
					                    $(this).val("");
					                }
					            });
					            
					            bm_name.blur(function () {
						        	var value = $(this).val().replace(/(^\s*)|(\s*$)/g, "");
						        	if(value!="" && value!="输入名称"){
							        	alert("haha");
							            $.ajax({
							                url:'/jrjw/a/documentmenu/documentMenuInfo/save',
							                data:{
							                	"name":encodeURI(value),
							                	"parentId":0,
							                	"parentIds":null
							                },
							                success: function (aa) {
							                		value=="输入名称"
							                    	window.location.reload();
							                }
							            });	 	
						        	}else if(value==""){
						        		alert("新部门名称不能为空")
						        		return false;
						        	}
						        });
		            	}
		            	else{
		            		return false;
		            	}
				    } else {
						var msg = "您真的确定修添加新部门吗？";
		            	if(confirm(msg)==true){
				            $("#add_input").css("display", "block");
				            var bm_name = $("#bm_name");
				            bm_name.val("输入名称");
				            bm_name.focus();
				            bm_name.click(function () {
				                if ($(this).val() != "") {
				                    $(this).val("");
				                }
				            });
				            
				            bm_name.blur(function () {
					        	$("#add_input").css("display", "none");
					        	var value = $(this).val().replace(/(^\s*)|(\s*$)/g, "");
					        	if(value!="" && value!="输入名称"){
						        	alert("haha");
						            $.ajax({
						                url:'/jrjw/a/documentmenu/documentMenuInfo/save',
						                data:{
						                	"name":encodeURI(value),
						                	"parentId":0,
						                	"parentIds":null
						                },
						                success: function (aa) {
						                    	window.location.reload();
						                }
						            });	 	
					        	}else{
					        		return false;
					        	}
					        });
		            	}else{
		            		return false;
		            	}
				    }
		        });
			
		    }

	       
	        /*树形下拉菜单  */
	        treeMenu();
	        function treeMenu(){
		        $(".subNav").click(function () {
		            $(this).toggleClass("currentDd").siblings(".subNav").removeClass("currentDd");
		            $(this).toggleClass("currentDt").siblings(".subNav").removeClass("currentDt");

		            // 修改数字控制速度， slideUp(500)控制卷起速度
		            $(this).next(".navContent").slideToggle(500).siblings(".navContent").slideUp(500);
		        })	
	        }
	        /*删除文件夹*/
	        folderDelete();
	        function folderDelete(){
	        	$('.db_folder').contextMenu('myMenu2', {
	        		bindings: {
	        			'deleteFolder':function(t){
	        				alert(1);
	        			}
	        		}
	        	});
	        }
	        /*左侧树形右键*/
	        treeRightC();
	        function treeRightC(){
	        	$('.subNav').contextMenu('myMenu1', {
		            bindings: {
		                'up': function (t) {
		                	var msg = "您真的确定向上移动该部门吗？";
		                	if(confirm(msg)==true){
			                    if ($(t).prevAll("div").length != 0) {
			                    	var theId= $(t).children().val();
			                    	var prevId = $(t).prevAll("div").first().children().val();
			                    	console.log(theId);
			                    	console.log(prevId);
 			                    	$.ajax({
			        	                url:'/jrjw/a/documentmenu/documentMenuInfo',
			        	                data:{
			        	                	"id":encodeURI(theId),
			        	                	"preId":encodeURI(prevId),
			        	                	"upOrDown": "up"
			        	                },
			        	                success :function(){
			        	                	window.location.reload();
			        	                }
			                    	}); 
			                        
			                    } else {
			                        alert("已经是第一个部门了")
			                    }
		                	}else{
		                		return false;
		                	}
		                },
		                'down': function (t) {
		                	var msg = "您真的确定向下移动该部门吗？";
		                	if(confirm(msg)==true){
		                		if ($(t).nextAll("div").length != 0) {
			                    	var theId= $(t).children().val();
			                    	var nextId = $(t).nextAll("div").first().children().val();
			                    	console.log(theId);
			                    	console.log(nextId);
	 			                    	$.ajax({
			        	                url:'/jrjw/a/documentmenu/documentMenuInfo',
			        	                data:{
			        	                	"id":encodeURI(theId),
			        	                	"preId":encodeURI(nextId),
			        	                	"upOrDown":"down"
			        	               	},
			        	               	success :function(){
			        	                	window.location.reload();
			        	                }
			                    	});
			                       
			                    } else {
			                        alert("已经是最后一个部门了")
			                    }
		                	}else{
		                		return false;
		                	}
		                },
		                'rename': function (t) {
						    var isChrome = window.navigator.userAgent.indexOf("Chrome") !== -1;
						    if (isChrome) {
						    	alert("谷歌浏览器");
			                	var msg = "您真的确定修改该部门名称吗？";
			                	if(confirm(msg)==true){
				                	var flgText =$(t).text();
									var flg=$(t).children();
									var flgVal=flg.val();
									console.log(flgText)
									console.log(flgVal)
 				                    	$(t).text("");
										console.log($(t).text())
				                        var oInput = $("<input class='oInput'/>");
				                        $(oInput).appendTo($(t));
				                        oInput.css("display","block");
				                       /*  oInput.attr("value","输入名称"); */
 				                        oInput.click(function(){
 						/*                     if ($(this).val() != "") {
 						                            $(this).val("");
 						                       } */
 				                        	oInput.focus();
				                        }) 
				                        oInput.blur(function(){
				                        	if($(this).val()==""||$(this).val()==flgText){
				                        		console.log("ok")
				                        		$(t).append(flg);
				                        		$(t).append(flgText);
				                        		$(this).remove();
				                        	}else{
					                            var value =$(this).val();
					                            $(this).remove();
					                            $.ajax({
					        		                url:'/jrjw/a/documentmenu/documentMenuInfo/rename',
					        		                data:{
					        		                	"name":encodeURI(value),
					        		                	"id":encodeURI(flgVal)
					        		                },
					        		                success:function(aa){
					        		                	  if (aa.result && aa.result == "yes"){
					        		                		  $(t).append(flg);
									                          $(t).append(value);
					        		                	  }
					        		                }
					                            });
				                        	}
				                        });
			                	}else{
			                		return false;
			                	}
						    }else{
			                	var msg = "您真的确定修改该部门名称吗？";
			                	if(confirm(msg)==true){
				                	var flgText =$(t).text();
									var flg=$(t).children();
									var flgVal=flg.val();
				                        $(t).text("");
				                        var oInput = $("<input class='oInput'/>");
				                        $(oInput).appendTo($(t));
				                        oInput.css("display","block");
				                        oInput.focus();
				                        oInput.blur(function(){
				                        	if($(this).val()==""||$(this).val()==flgText){
				                        		alert("修改名称不能为空")
				                        		$(t).append(flg);
				                        		$(t).append(flgText);
				                        		$(this).remove();
				                        	}else{
					                            var value =$(this).val();
					                            $(this).remove();
					                            $.ajax({
					        		                url:'/jrjw/a/documentmenu/documentMenuInfo/rename',
					        		                data:{
					        		                	"name":encodeURI(value),
					        		                	"id":encodeURI(flgVal)
					        		                },
					        		                success:function(aa){
					        		                	  if (aa.result && aa.result == "yes"){
					        		                		  $(t).append(flg);
									                          $(t).append(value);
					        		                	  }
					        		                }
					                            });
				                        	}
				                        }); 
			                	}else{
			                		 return false;
			                	}
						    }
		                },
		                'delete': function (t) {
		                	var msg = "您真的确定要该部门吗？";
		                	if(confirm(msg)==true){
			                	var deleteVal=$(t).children().val();
			                	console.log(deleteVal);
			                	 $.ajax({
			     	                url:'/jrjw/a/documentmenu/documentMenuInfo/delete',
			     	                data:{
			     	                	id:deleteVal
			     	                },
			     	               success: function (aa) {
			   	                    	window.location.reload();
			   	                }
			     			 });
		                    }else{
		                        return false;
		                    }
		                },
		                'add_file': function (t) {
		                	 var isChrome = window.navigator.userAgent.indexOf("Chrome") !== -1;
							    if (isChrome) {
							    	alert("谷歌浏览器");
				                	var msg = "您确定新建文件夹吗？";
				                	if(confirm(msg)==true){
					                    var obj = $("<input value='新建文件夹' class='newName'>");
					                    obj.insertAfter($(t));
					                    obj.click(function () {
					                    	obj.focus();
					                        if ($(this).val() != "") {
					                            $(this).val("");
					                        }
					                    });
					                    obj.blur(function () {
					                    	if(obj.val()!=""&&obj.val()!="新建文件夹"){
						                        obj.css("display", "none");
						                        var value = $(this).val();
						                        var parentId=$(t).children().val();
						        	             $.ajax({
						        	                url:'/jrjw/a/documentmenu/documentMenuInfo/save',
						        	                data:{
						        	                	"name":encodeURI(value),
						        	                	"parentId":encodeURI(parentId),
						        	                	"parentIds":null
						        	                },
					 	        	                 success: function (aa) {
					 	        	                	window.location.reload();
						        	                } 
						        	            });   
					                    	}else{
					                    		obj.css("display", "none");
					                    	} 
					                    });
				                	}else{
				                		return false;
				                	}
							    }else{
				                	var msg = "您确定新建文件夹吗？";
				                	if(confirm(msg)==true){
					                    var obj = $("<input value='新建文件夹' class='newName'>");
					                    obj.insertAfter($(t));
					                    obj.focus();
					                    obj.click(function () {
					                        if ($(this).val() != "") {
					                            $(this).val("");
					                        }
					                    });
					                    obj.blur(function () {
					                    	if(obj.val()!=""&&obj.val()!="新建文件夹"){
						                        obj.css("display", "none");
						                        var value = $(this).val();
						                        var parentId=$(t).children().val();
						        	             $.ajax({
						        	                url:'/jrjw/a/documentmenu/documentMenuInfo/save',
						        	                data:{
						        	                	"name":encodeURI(value),
						        	                	"parentId":encodeURI(parentId),
						        	                	"parentIds":null
						        	                },
					 	        	                 success: function (aa) {
					 	        	                	window.location.reload();
						        	                } 
						        	            });   
					                    	}else{
					                    		obj.css("display", "none");
					                    	} 
					                    });
				                	}else{
				                		return false;
				                	}
							    }
		                }
		            }
		        });
	        }
	        
        
        	/*点击返回  */
        	clickBack();
        	function clickBack(){
                $("#back").click(function () {
                    $("#folder_win").css({"display": "block", "z-index": 10});
                    $("#file_win").css({"display": "none", "z-index": 0});
                    $(".db_folder").each(function(index,item){
                    	$(item).css("border-color","#fdfefe");
                    })
                });
        	}
	});
	</script>
</head>
<body>
<div id="box">
    <div id="head">
        <div id="head_xia">
            <ul>
                <li class="top2">
                                                        文件搜索：
                <input type="text" value="文件搜索" id="search_input"/>
                <img src="${ctxStatic}/myhao/images/search.png" id="seachEnter"/>
                </li>
            </ul>
        </div>
    </div>
    <div id="food">
        <div id="tree" class="food_child">
            <div class="add_menu">
                <!--添加部门按钮-->
                <p id="add_menu">+添加部门</p>
            </div>

            <!--左侧树形-->
            <div class="subNavBox">
            	<c:forEach items="${totalList}" var="map">
            	<c:forEach items="${map}" var="entry" varStatus="vs">
                <div class="subNav" id="cw"><input type="hidden" value="${entry.key.id} " id="department_name"/>${entry.key.name}</div>
                <ul class="navContent " id="cw_ul">
                	<c:forEach items="${entry.value}" var="menu">
                    <li><a href="#"><input type="hidden" value="${menu.id}" id="file_name" class="file_name"/>${menu.name}</a></li>
                    </c:forEach>	
                </ul>
                </c:forEach>
                </c:forEach>
            </div>

            <!--树形添加部门-->
            <div id="add_input">
                <ul>
                    <li>
                        <input type="text" value="输入名称" id="bm_name"/>
                    </li>
                </ul>
            </div>
            <!--树形右击菜单-->
            <div class="contextMenu" id="myMenu1">
                <ul>
                    <li id="delete"><img src="${ctxStatic}/myhao/images/cross.png"/>删除部门</li>
                    <li id="up"><img src="${ctxStatic}/myhao/images/up.png"/>上移</li>
                    <li id="down"><img src="${ctxStatic}/myhao/images/down.png"/>下移</li>
                    <li id="rename"><img src="${ctxStatic}/myhao/images/rename.png"/>重命名</li>
                    <li id="add_file"><img src="${ctxStatic}/myhao/images/New_File.png"/>新建文件夹</li>
                </ul>
            </div>
            <div class="contextMenu" id="myMenu2">
                <ul>
                    <li id="delete_folder"><img src="${ctxStatic}/myhao/images/delete_folde.png"/>删除文件夹</li>
                </ul>
            </div>
            <div class="contextMenu" id="myMenu3">
                <ul>
                    <li id="delete_file"><img src="${ctxStatic}/myhao/images/delete_file.png"/>删除文件</li>
                    <li id="download"><img src="${ctxStatic}/myhao/images/upload_file.png"/>下载文件</li>
                </ul>
            </div>
        </div>
        <!--右侧文件部门-->
        <div id="file" class="food_child">
        
        	<div class="defaultWindow">
                <div></div>
                <span>请选择您所在的部门,如部门不存在请点击"添加部门"</span>
            </div>
            <!--文件夹窗口-->
            <div id="folder_win">
                <div class="top3">
                    <ul class="top3_ul">
                        <li>
                            <a href="javascript:void(0)" id="new_folder">
                                <img src="${ctxStatic}/myhao/images/share.png" alt=""/>
                                分享
                            </a>
                        </li>
                    </ul>
                </div>
                <div id="top3_next">
                    <ul class="top3_next_ul" id="brunchFiles">
                        
                    </ul>
                </div>
            </div>

            <!--文件窗口-->
            <div id="file_win">
                <!--表头-->
                <div class="top2">
                    <ul class="top2_ul">
                        <li>
                            <a href="javascript:void(0)" id="back">
                                <img src="${ctxStatic}/images/fanhui.png" alt=""/>
                                返回
                            </a>
                        </li>
                        <li>
                            <a href="javascript:void(0)" id="add_files">
                                <img src="${ctxStatic}/images/file_upload.png" alt=""/>
                                上传
                            </a>
                        </li>
                    </ul>
                </div>
                <!--内容部门-->
                <div id="top2_next">
                    <ul class="top2_next_ul" id="thirdLevel">
                    </ul>
                </div>
            </div>
            
            <!--上传窗口  -->
            <div id="scWin">
                    <div class="top4">
                        <ul class="top4_ul">
                            <li>
                                <a href="javascript:void(0)" id="winBack">
                                    <img src="${ctxStatic}/images/fanhui.png" alt=""/>
                                    返回
                                </a>
                            </li>
                        </ul>
                    </div>
                <div id="formWindow">
                        <form id= "uploadForm" enctype="multipart/form-data">  
				          <input type="hidden" name="id"/>  
				                                  上传文件： <input type="file" name="file" id="fileId"/><br/>  
				          <input type="button" value="上传" id="btnsubmit"/>  
    					</form>  
                </div>
            </div>
            <!--分享窗口  -->
             <div id="sharewin">
                    <div class="top5">
                        <ul class="top5_ul">
                            <li>
                                <a href="javascript:void(0)" id="chareBack">
                                    <img src="${ctxStatic}/images/fanhui.png" alt=""/>
                                    返回
                                </a>
                            </li>
                        </ul>
                    </div>
                	<div id="shareWindow">
                		 <ul class="shareWindow_ul"></ul>
                		<input type="button" value="选择分享" id="count"/>
                	</div>
            </div>
            <div class="contextMenu" id="myMenu2">
                <ul>
                    <li id="deleteFolder"><img src="${ctxStatic}/myhao/images/cross.png"/>删除文件夹</li>
                </ul>
            </div>
        </div>
    </div>
</div>
</body>
</html>