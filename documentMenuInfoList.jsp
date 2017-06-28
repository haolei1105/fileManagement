<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="org.apache.shiro.web.filter.authc.FormAuthenticationFilter"%>
<%@ include file="/WEB-INF/views/include/taglib.jsp"%>

<html>
<head>
<meta name="decorator" content="default" />
<%@include file="/WEB-INF/views/include/treeview.jsp"%>
    <meta name="decorator" content="blank" />
    <meta http-equiv="pragma" content="no-cache"/>
    <meta http-equiv="cache-control" content="no-cache"/>
    <title>文件管理模块</title>
    <link type="text/css" rel="stylesheet" href="${ctxStatic}/myhao/css/reset.min.css"/>
    <link type="text/css" rel="stylesheet" href="${ctxStatic}/myhao/css/index.css"/>
   	
    <script charset="UTF-8" type="text/javascript" src="${ctxStatic}/myhao/js/jquery.contextmenu.r2.js"></script>
    <script charset="UTF-8" type="text/javascript" src="${ctxStatic}/myhao/js/ajaxfileupload.js"></script>
	<style>
		#box #food #file .defaultWindow div {
          padding: 250px 165px 10px 140px;
          width: 488px;
          background: url(${ctxStatic}/myhao/images/start.png) no-repeat center center;         
		}
	</style>
	<script>
	$(document).ready(function() {
		
		/*解决IE8下  console未定义*/
		window.console = window.console || (function(){   
		    var c = {}; c.log = c.warn = c.debug = c.info = c.error = c.time = c.dir = c.profile   
		    = c.clear = c.exception = c.trace = c.assert = function(){};   
		    return c;   
		})();  
		/*点击部门初始页消失  */
		statrWin();
		function statrWin(){
			/*点击某个部门文件部分首页消失，部门文件显示*/	
			 $(".subNav").click(function(){
					var startVal=$(this).children().val();//获取部门下隐藏域的input的value值，确定点击的是哪个部门。
					//校验是否用户所在部门，控制权限
					var flag=false;
					$.ajax({
     	                url:'${ctx}/documentmenu/documentMenuInfo/brunchMenuValidate',
     	                data:{
     	                	officeId:startVal //机构的ID
		                },
		                success: function (data) {
	     	            	  if(data.resultFlag=='failed'){
						          //查看权限
						          //shareFiles/newfolder屏蔽
						          $("#shareFiles").hide();
	     	            		  $("#newfolder").hide();
				
						      }else{
						    	  flag=true;
						    	  //管理权限
						    	  //shareFiles/newfolder显示
						    	  $("#shareFiles").show();
	     	            		  $("#newfolder").show();
						      }
   	                	}
                	 });
					 $.ajax({
			                url:'/jrjw/a/documentmenu/documentMenuInfo/brunchMenu',
			                data:{
			                	officeId:startVal
			                },
			                success:function(menuList){
			                	$("#brunchFiles").children().remove();//返回成功删除该文件窗口下的所有文件夹；
			                	//右侧显示所属机构
								if(menuList && menuList.length>0){
									$("#departmentName").children('p').text(menuList[0].officeName);
									for (var i = 0; i <menuList.length; i++) {
										var div="<li class='db_folder'>"+
											"<input type='hidden' value='"+menuList[i].id+"'/>"+
				                            "<img src='${ctxStatic}/images/file.png' alt=''/>"+
				                            "<p>"+menuList[i].menuName+"</p>"+
				                       "</li>";
				                       $("#brunchFiles").append(div);//创建新的文件夹；
									}
									
									/*单机文件夹背景色变化  */
									$(".db_folder").each(function(){//循环每个文件夹
 										 	var browser=navigator.appName;
							                var b_version=navigator.appVersion;
							                var version=b_version.split(";");
							                var trim_Version=version[1].replace(/[ ]/g,"");
							                if(browser=="Microsoft Internet Explorer" && trim_Version=="MSIE8.0"){
										        $(this).toggle(function(){
									                $(this).css("border-color","#128DDD");//点击文件夹该文件件夹边框颜色切换   
									                /* console.log($(this).css("border-color")); */
										        },
									            function(){
									                $(this).css("border-color","#fdfefe");
									                });
							                }else{
							                	$(this).toggle(function(){
									                $(this).addClass('a')
									                $(this).removeClass('b'); 
										        },
									            function(){
									                $(this).removeClass('a');
									                $(this).addClass('b')
												});
							                }
									});
									if(flag){
										/*右键删除文件夹*/
										$('.db_folder').contextMenu('myMenu1', {//文件夹右击事件
			            					bindings: {
			            						'delete_folder': function (t) {
			            							var delete_folderId=$(t).children('input').first().val();
			            							$.ajax({
		            			     	                url:'${ctx}/documentmenu/documentMenuInfo/deleteMenuValidate',
		            			     	                data:{
		            			     	                	menuId:delete_folderId//将要删除的文件夹ID
		            			     	                },
		            			     	                success: function (data) {
		            			     	                	var submit = function (v, h, f) {
		  		            		                          if (v == true){
		  		            		                        	 //删除文件夹
		 	            			     	            		 $.ajax({
		 	     	            			     	                url:'${ctx}/documentmenu/documentMenuInfo/deleteMenu',
		 	     	            			     	                data:{
		 	     	            			     	                	menuId:delete_folderId//将要删除的文件夹ID
		 	     	            			     	                },
		 	     	            			     	                success: function (data) {
		 		     	            			     	            	  if(data.resultFlag=='failed'){
		 		     	            								        	$.jBox.info(data.resultDesc);
		 		     	            								      }else{
		 		     	            								    	  $(t).remove();
		 		     	            								    	  //重新加载左侧树形--待调整
		 		     	            								    	 // location='${ctx}/documentmenu/documentMenuInfo';
		 		     	            								      }
		 	     	            			   	                	}
		 	     	            			                	 });  
		  		            		                          }else if (v == false){
		  		            		                        	  return true;//关闭
		  		            		                          }
		  		            		                          return true;//关闭
		  		            		                      };
		  		            		       				  $.jBox.confirm(data.resultDesc, "警告", submit,{ buttons: { '确认': true, '取消': false} });
		            			   	                	}
		            			                	});
		            			                },
			            						'rename': function (t) {
			            							var flgText=$(t).children('p').text();
			            							console.log(flgText);
			            							$(t).children('p').text("");
			            							var oInput = $("<input class='oInput'/>");
			            							$(t).append(oInput);
			            							$(oInput).focus();
			            							$(oInput).blur(function(){
			            								var value=$(this).val();
			            								if(value!="" && value!=flgText){
			            									var flgId=$(this).parent().children('input').first().val();
			            									$(this).remove();
	 		            									$.ajax({
								        		                url:'/jrjw/a/documentmenu/documentMenuInfo/menuRename',
								        		                data:{
								        		                	"menuId":flgId,
								        		                	"menuName":encodeURI(value)
								        		                },
								        		                success:function(data){
								        		                	  if (data.resultFlag == "success"){
							            								  $(t).children('p').text(value);
							            									
								        		                	  }
								        		                }
								                            });
			            								}else if(value=="" || value==flgText){
			            									$(t).children('p').text(flgText);
			            									$(this).remove();
			            								}
			            							});
			            						}
			           						 }
										});
									}
									/*双击文件夹，进入该文件内  */
									/* var folderId=""; */
									 $(".db_folder").children("img").each(function(index,item){//循环文件夹 图片
										 $(this).dblclick(function(){//双击该文件夹图片
											 var menuName=$(this).parent().children('p').text();
											 $("#fileNames").children('p').text(menuName);
											 folderId = $(this).parent().children().first().val();//变量保存文件夹下的隐藏域的value（ID）值；
											 $.ajax({
									                url:'/jrjw/a/documentmenu/documentMenuInfo/brunchFile',
									                cache:false, 
									                data:{
									                	menuId:folderId
									                },
									                success :function(fileList){
									                	if(fileList && fileList.length>0){
									                		$("#folder_win").css({"display": "none", "z-index": 0});
									    		            $("#file_win").css({"display": "block", "z-index": 10});//具体文件窗口展示
									    		            $("#search_win").css({"display": "none", "z-index": 0});
										                	$(".top2_next_ul").css("display", "block");
										                	$("#thirdLevel").children().remove();//具体文件窗口下的内容清空
									                		for (var i = 0; i <fileList.length; i++) {
									                			var div="<li class='db_file'>"+
									                			"<input type='hidden' value='"+fileList[i].id+"'/>"+
								                            	"<img src='${ctxStatic}/images/dbfile.png' alt=''/>"+
								                            	"<p>"+fileList[i].fileName+"</p>"+
								                            	"</li>";
								                            	$("#thirdLevel").append(div);//后台获取插入新的文件内容，插入到具体文件窗口
									                		}
									                		 /*右键删除文件  */
									                		 if(!flag){
																	$('.db_file').contextMenu('myMenu3', {
										            					bindings: {
										            						'download':function (t) {//右键文件选择下载文件
									            		                		var download_fileId=$(t).children("input").val();
										            							var url = '/jrjw/a/documentmenu/documentMenuInfo/download';
									            		                		var form = $("<form>");
									            		                		form.attr("style","display:none");
									            		                		form.attr("target","");
									            		                		form.attr("method","post");
									            		                		form.attr("action",url);
									            		                		var input1 = $("<input>");
									            		                		input1.attr("type","hidden");
									            		                		input1.attr("name","fileId");
									            		                		input1.attr("value",download_fileId);
									            		                		$("body").append(form);
									            		                		form.append(input1);
									            		                		form.submit();
									            		                		form.remove();
									            		                		//若文件不存在或者下载失败，需处理返回值 
									            		                		/*
									            			                	$.ajax({
									            			     	                url:'/jrjw/a/documentmenu/documentMenuInfo/download',
									            			     	                data:{
									            			     	                	fileId:download_fileId
									            			     	                },
									            			     	               success: function (data) {
									            			     	            	  if(data.resultFlag=='failed'){
									            								        	$.jBox.info(data.resultDesc);
									            								      }
									            			   	                   }
									            			     			 	});
									            		                		*/
										            						}
										           						 }
																	}); 
									                		 }else{
									                			 yy(); 
									                		 }
								                			 function yy(){
																	$('.db_file').contextMenu('myMenu2', {
										            					bindings: {
										            							'delete_file': function (t) {//右键文件选择删除文件
											            							var submit = function (v, h, f) {
											            		                          if (v == true){
											            		                        	  var delete_fileId=$(t).children("input").val();
													            			                	$.ajax({
													            			     	                url:'/jrjw/a/documentmenu/documentMenuInfo/deleteFile',
													            			     	                data:{
													            			     	                	fileId:delete_fileId//将要删除的文件ID
													            			     	                },
													            			     	               success: function (data) {
													            			     	            	  if(data.resultFlag=='failed'){
													            								        	$.jBox.info(data.resultDesc);
													            								      }else{
													            								    	  $(t).remove()
													            								      }
													            			   	                	}
													            			                	});
											            		                          }else if (v == false){
											            		                        	  return true;//关闭
											            		                          }
											            		                          return true;//关闭
											            		                      };
											            		       				  $.jBox.confirm("确认删除该文件吗？", "警告", submit,{ buttons: { '确认': true, '取消': false} });
											            						},
										            						'download':function (t) {//右键文件选择下载文件
									            		                		var download_fileId=$(t).children("input").val();
										            							var url = '/jrjw/a/documentmenu/documentMenuInfo/download';
									            		                		var form = $("<form>");
									            		                		form.attr("style","display:none");
									            		                		form.attr("target","");
									            		                		form.attr("method","post");
									            		                		form.attr("action",url);
									            		                		var input1 = $("<input>");
									            		                		input1.attr("type","hidden");
									            		                		input1.attr("name","fileId");
									            		                		input1.attr("value",download_fileId);
									            		                		$("body").append(form);
									            		                		form.append(input1);
									            		                		form.submit();
									            		                		form.remove();
									            		                		//若文件不存在或者下载失败，需处理返回值 
									            		                		/*
									            			                	$.ajax({
									            			     	                url:'/jrjw/a/documentmenu/documentMenuInfo/download',
									            			     	                data:{
									            			     	                	fileId:download_fileId
									            			     	                },
									            			     	               success: function (data) {
									            			     	            	  if(data.resultFlag=='failed'){
									            								        	$.jBox.info(data.resultDesc);
									            								      }
									            			   	                   }
									            			     			 	});
									            		                		*/
										            						}
										           						 }
																	}); 
										                		 }
									                	}else{
									                		$("#folder_win").css({"display": "none", "z-index": 0});
									    		            $("#file_win").css({"display": "block", "z-index": 10});
									    		            $("#search_win").css({"display": "none", "z-index": 0});
										                	$(".top2_next_ul").css("display", "block");
										                	$(".kk").css({"display": "none", "z-index": 0});
										                	$("#thirdLevel").children().remove();
									                	}
									                }
											 });
										 });
									 });
								}
			             }
					 });
		            $(".defaultWindow").css({"display": "none", "z-index": 0});
		            $("#folder_win").css({"display": "block", "z-index": 10});
		            $("#file_win").css({"display": "none", "z-index": 0});
		            $("#search_win").css({"display": "none", "z-index": 0});
		         });
		};
		/*文件上传*/
		 /*点击X隐藏图层*/
		 sc();
		 function sc(){
			 $("#close1").click(function(){
				 console.log("11111")
		         $("#modal1").css("display","none");
		         $("#opcity1").css("display","none");
		         $("#list_list2").html("");
			 });
        $("#add_files").click(function(){//点击表头上传按钮，跳转到上传界面；
       	 console.log("ttttt")
	         $("#modal1").css("display","block");
	         $("#opcity1").css("display","block");
	         var oDiv =$("#list_list2");
	         var oForm =document.createElement("form");
	         $(oForm).attr({
	        	 "id":"uploadForm",
	        	 "enctype":"multipart/form-data"
	         });
	         var input1=document.createElement("input");
	         $(input1).attr({
	                "type":"hidden",
	                "name": "id"
	         });
	         var input2=document.createElement("input");
	         $(input2).attr({
	                "type":"file",
	                "name": "file",
	                "id":"fileId"
	         });
	         var input3=document.createElement("input");
	         $(input3).attr({
	                "type":"button",
	                "value": "确认上传",
	                "id":"btnsubmit"
	         })
	         $(oForm).append($(input1));
	         $(oForm).append($(input2));
	         $(oForm).append($(input3));
	         $(oDiv).append($(oForm));
			 $("#btnsubmit").click(function(){//点击确认上传按钮
	        	 	var noNull=$("#fileId");
	        	    noNull.val()!="";
					var uploadForm=$("#uploadForm");
				    uploadForm.children().first().val(folderId);//设置该文件所在文件夹的ID值保存到form表单的隐藏域的value值中；
				    console.log( uploadForm.children().first().val())
				    var tt=uploadForm.children().first().val();
				    var noNull=$("#fileId");
				    if(noNull.val()!=""&&noNull.val()!="未选择任何文件"){
					    $.ajaxFileUpload({
					    	 url: "/jrjw/a/documentmenu/documentMenuInfo/upload?menuId="+tt,//用于文件上传的服务器端请求地址
						     secureuri: false,//一般设置为false
						     fileElementId :'fileId',//file控件的id
						     dataType: 'json',
						     error: function() { alert('加载错误！'); },//服务器响应失败处理函数
						     success: function(data) {//服务器成功响应处理函数
						         if(data.resultFlag=='success'){
						        	 $("#modal1").css("display","none");
				        			 $("#opcity1").css("display","none");
				        			 $("#list_list2").html("");
				        			 $.ajax({
							                url:'/jrjw/a/documentmenu/documentMenuInfo/brunchFile',
							                cache:false, 
							                data:{
							                	menuId:tt
							                },
							                success :function(fileList){
							                	if(fileList && fileList.length>0){
							                		$("#folder_win").css({"display": "none", "z-index": 0});
							    		            $("#file_win").css({"display": "block", "z-index": 10});//具体文件窗口展示
								                	$(".top2_next_ul").css("display", "block");
								                	$("#search_win").css({"display": "none", "z-index": 0});
								                	$("#thirdLevel").children().remove();//具体文件窗口下的内容清空
							                		for (var i = 0; i <fileList.length; i++) {
							                			var div="<li class='db_file'>"+
							                			"<input type='hidden' value='"+fileList[i].id+"'/>"+
						                            	"<img src='${ctxStatic}/images/dbfile.png' alt=''/>"+
						                            	"<p>"+fileList[i].fileName+"</p>"+
						                            	"</li>";
						                            	$("#thirdLevel").append(div);//后台获取插入新的文件内容，插入到具体文件窗口
							                		}
								                
							                		 /*右键删除文件  */
							                		 yy();
							                		function yy(){
														$('.db_file').contextMenu('myMenu2', {
							            					bindings: {
							            						'delete_file': function (t) {//右键文件选择删除文件
							            							var submit = function (v, h, f) {
							            		                          if (v == true){
							            		                        	  var delete_fileId=$(t).children("input").val();
									            			                	$.ajax({
									            			     	                url:'/jrjw/a/documentmenu/documentMenuInfo/deleteFile',
									            			     	                data:{
									            			     	                	fileId:delete_fileId//将要删除的文件ID
									            			     	                },
									            			     	               success: function (data) {
									            			     	            	  if(data.resultFlag=='failed'){
									            								        	$.jBox.info(data.resultDesc);
									            								      }else{
									            								    	  $(t).remove()
									            								      }
									            			   	                	}
									            			                	});
							            		                          }else if (v == false){
							            		                        	  return true;//关闭
							            		                          }
							            		                          return true;//关闭
							            		                      };
							            		       				  $.jBox.confirm("确认删除该文件吗？", "警告", submit,{ buttons: { '确认': true, '取消': false} });
							            						},
							            						'download':function (t) {//右键文件选择下载文件
						            		                		var download_fileId=$(t).children("input").val();
							            							var url = '/jrjw/a/documentmenu/documentMenuInfo/download';
						            		                		var form = $("<form>");
						            		                		form.attr("style","display:none");
						            		                		form.attr("target","");
						            		                		form.attr("method","post");
						            		                		form.attr("action",url);
						            		                		var input1 = $("<input>");
						            		                		input1.attr("type","hidden");
						            		                		input1.attr("name","fileId");
						            		                		input1.attr("value",download_fileId);
						            		                		$("body").append(form);
						            		                		form.append(input1);
						            		                		form.submit();
						            		                		form.remove();
						            		                		//若文件不存在或者下载失败，需处理返回值 
						            		                		/*
						            			                	$.ajax({
						            			     	                url:'/jrjw/a/documentmenu/documentMenuInfo/download',
						            			     	                data:{
						            			     	                	fileId:download_fileId
						            			     	                },
						            			     	               success: function (data) {
						            			     	            	  if(data.resultFlag=='failed'){
						            								        	$.jBox.info(data.resultDesc);
						            								      }
						            			   	                   }
						            			     			 	});
						            		                		*/
							            						}
							           						 }
														}); 
							                		 }
						                        
							                	}else{
							                		$("#folder_win").css({"display": "none", "z-index": 0});
							    		            $("#file_win").css({"display": "block", "z-index": 10});
								                	$(".top2_next_ul").css("display", "block");
								                	$(".kk").css({"display": "none", "z-index": 0});
								                	$("#search_win").css({"display": "none", "z-index": 0});
								                	$("#thirdLevel").children().remove();
							                	}
							                }
									 });
						         }else{
						        	 $.jBox.info(data.resultDesc);
						        	 $("#modal1").css("display","none");
							         $("#opcity1").css("display","none");
							         $("#list_list2").html("");
						         }
						     }
					    });
				    }else{
				    	$.jBox.info("上传文件不能为空！");
				    	return	false;
				    }
				});
        });
		}
		 
		 
		 	/*创建新文件夹*/
		 	addNewFloder();
		 	function addNewFloder(){
		 		$("#newfolder").click(function(){
		 			var brunchFiles=$("#brunchFiles");
		 			var oFragmeng = document.createDocumentFragment();
			 		var oli =document.createElement("li");
			         $(oli).attr({
			        	 "class":"db_folder"
			         });
			         var ValInput=document.createElement("input");
			         $(ValInput).attr({
			                "type":"hidden",
			                "value": ""
			         });
			         var oImg=document.createElement("img");
			         $(oImg).attr({
			                "src":"${ctxStatic}/images/file.png"
			         });
			         var oP=document.createElement("p");
			         var NameInput=document.createElement("input");
			         $(NameInput).attr({
			        	 "class":"oInput"
			         });
			         $(oli).append(ValInput);
			         $(oli).append(oImg);
			         $(oli).append(oP);
			         $(oli).append(NameInput);
			         $(oFragmeng).append(oli);
			         $(brunchFiles).append(oFragmeng);
			         $(NameInput).focus();
					 $(NameInput).blur(function(){
						 var value=$(this).val();
							if(value!=""){
								$.ajax({
	        		                url:'/jrjw/a/documentmenu/documentMenuInfo/saveMenu',
	        		                data:{
	        		                	"menuName":encodeURI(value)
	        		                },
	        		                success:function(data){
	        		                	  if (data.resultFlag == "success"){
	           									$(NameInput).parent().children('p').text(value);
	        		                		   	$(NameInput).remove();
	        		                	  }else{
	        		                		  $.jBox.info(data.resultDesc);
	        		                	  }
	        		                }
	                            }); 
							}else{
								$(this).parent().remove();
							} 
					});
		 		});
		 	}
		    /*文件夹分享  */
		    fx();
		    function fx(){
		    	/*分享那个文件夹*/
		    	var wjjId="";
				 $("#shareFiles").click(function(){
			    	 $(".db_folder").each(function(){//判断文件夹点击选中，IE不识别rgb
 						 if($(this).css("background-color")=="rgb(204, 235, 248)"||$(this).css("background-color")=="#ccebf8"||$(this).css("border-color")=="#128ddd"){
							 wjjId+=$(this).children().first().val();//变量拼接该文件夹的ID值
								 wjjId+=",";//拼接逗号
						 }
					 });
					 if(wjjId!=""){//确认有文件夹被选中，变量的内容不为空
				         $("#modal").css("display","block");
				         $("#opcity").css("display","block");
				         //加载待分享机构
				         function bindHTML(data){
				        	 var str="";
 				        	 $.each(data,function(index,item){
				        		 str+="<li>";
				        		 	str+='<input type="hidden" value='+item.id+'>';
				        		 	str+='<input type="checkbox" name="test" class="btnture il"/>';
				        		 	str+='<p class="il">'+item.name+'</p>';
				        		 str+="</li>";
				        	 });
				        	 var oDiv=$("#list_list1");
				        	 oDiv.html(str);
				         }
				         $.ajax({
	     	                url:'${ctx}/documentmenu/documentMenuInfo/loadWaitShareOfficeList',
	     	                data:{
			                	menuIds: wjjId.substring(0,wjjId.length-1)//文件夹的ID
			                },
	     	                success:bindHTML
	                	 });
						 $("#close").click(function(){
					         $("#modal").css("display","none");
					         $("#opcity").css("display","none");
					         wjjId="";
					         $("#list_list1").html("");
						 });
					 }else{
						 $.jBox.info("分享文件夹不能为空！");
					 }
				 });
				 $("#count").click(function(){
					 var newwjjId=wjjId.substring(0,wjjId.length-1);//去掉变量的字符串最后一个逗号，并保存到新的变量中；
					 var searchId="";
					 $(".btnture").each(function(){
						 if($(this).prop("checked")==true){//如果分享部门前复选框被选中；
							 searchId+=$(this).prevAll("input").first().val()/* .trim() IE8不支持删除字符串里所有空格*/;//获取该部门的下第一个隐藏域的ID值；
							 searchId+=",";//给变量拼接逗号；
						 }
					 });
					 var newsearchId=searchId.substring(0,searchId.length-1);//去除变量的最后一个逗号，并且保存到新的变量里；
 					 console.log(newwjjId)
					 console.log(newsearchId)
					 if(searchId!=""&&wjjId!=""){
						 $.ajax({
				                url:'/jrjw/a/documentmenu/documentMenuInfo/shareMenus',
				                data:{
				                	menuIds:newwjjId,//文件夹的ID
				                	officeIds:newsearchId//分享到的部门ID
				                },
				                success: function (data) {
				                	 $.jBox.info(data.resultDesc);
				                	 if(data.resultFlag=='success'){
								         $("#modal").css("display","none");
								         $("#opcity").css("display","none");
								         wjjId="";
								         $("#list_list1").html("");
				                	 }else{
								         $("#modal").css("display","none  ");
								         $("#opcity").css("display","none");
								         wjjId="";
								         $("#list_list1").html("");
				                	 }
				                	 /*问题同时分享2个文件夹   返回失败  */
						        }
						 }); 
					 }else{
						 $.jBox.info("分享部门不能为空！");
					 }
				 })
		    }
		    /*列表图形切换*/
		    $("#list1").click(function(){
		    	$(this).css("display","none");
		    	$("#list2").css("display","block");
		    	$(".kk").css({"display": "block", "z-index": 10});
		    	$("#folder_win").css({"display": "none", "z-index": 0});
	            $("#file_win").css({"display": "none", "z-index": 0});
	            $("#search_win").css({"display": "none", "z-index": 0});
		    });
		    $("#list2").click(function(){
		    	$(this).css("display","none");
		    	$("#list1").css("display","block");
		    	$(".kk").css({"display": "none", "z-index": 0});
		    	$("#folder_win").css({"display": "none", "z-index": 0});
	            $("#file_win").css({"display": "block", "z-index": 10});
	            $("#search_win").css({"display": "none", "z-index": 0});
		    })
		    /*所搜 功能 */
		    searchInput();
		    function searchInput(){
		    		var curSearch = $("#search");
		    	 	curSearch.click(function(){
		    	 		 $(this).focus();
		    	 		if ($(this).val()!= "") {
				            $(this).val("");
				        }
		    	 	 });
		            $(document).bind("click",function(e){    
		                if($(e.target).closest(".wrapper").length == 0){
		                //点击wrapper之外就则触发
		                  curSearch.val("文件搜索")
		                }
		             });
		            $(".search_btn").click(function(){
					       var valueSearch=$(this).parent().children('input').val();
					       console.log(valueSearch);
	 				    	   $.ajax({
		        	                url:'/jrjw/a/documentmenu/documentMenuInfo/searchFiles',
		        	                data:{
										fileName:encodeURI(valueSearch)
		        	                },
		        	                success :function(data){
		        	                	console.log(data);
		        	                	/* if(data!=null){ */
		  	        				     	 $(".defaultWindow").css({"display": "none", "z-index": 0});
			        				         $("#folder_win").css({"display": "none", "z-index": 0});
			        				         $("#file_win").css({"display": "none", "z-index": 0});
			        				         $(".kk").css({"display": "none", "z-index": 0});
			        				         $("#search_win").css({"display": "block", "z-index": 10});
		        	                		var str="";
			        	                	for(var key in data){
			        	                		str+='<ul class="top4_next_ul" style="display:block;">';
			        	                			str+='<p class="pStyle">'+key+'</p>';
		 	        	                		$.each(data[key],function(index,item){
			 	      				        		 str+='<li class="db_file">';
			 					        		 		str+='<input type="hidden" value='+item.id+'>';
			 					        		 		str+="<img src='${ctxStatic}/images/dbfile.png' alt=''/>";
			 					        		 		str+='<p>'+item.fileName+'</p>';
			 					        			 str+='</li>';
				        	                	})
				        	                	str+="</ul>";
			        	                	}
			        	                	var oDiv=$("#top4_next");
			        	                	oDiv.html(str);
			        	                	
											$('.db_file').contextMenu('myMenu3', {
				            					bindings: {
				            						'download':function (t) {//右键文件选择下载文件
			            		                		var download_fileId=$(t).children("input").val();
				            							var url = '/jrjw/a/documentmenu/documentMenuInfo/download';
			            		                		var form = $("<form>");
			            		                		form.attr("style","display:none");
			            		                		form.attr("target","");
			            		                		form.attr("method","post");
			            		                		form.attr("action",url);
			            		                		var input1 = $("<input>");
			            		                		input1.attr("type","hidden");
			            		                		input1.attr("name","fileId");
			            		                		input1.attr("value",download_fileId);
			            		                		$("body").append(form);
			            		                		form.append(input1);
			            		                		form.submit();
			            		                		form.remove();
				            						}
				           						 }
											}); 

		        	                	/* }else{
		        	                		return false;
		        	                	} */
		        	                },
		        	                error:function(){
		        	                	alert("系统内部出错，请联系管理员");
		        	                }
		                    	});    
		            })
				    curSearch.keyup(function(e) {
				       var valueSearch=$(this).val();
				       if(e.keyCode==13&&$(this).val()!=""&&$(this).val()!="文件搜索") {
 				    	   $.ajax({
	        	                url:'/jrjw/a/documentmenu/documentMenuInfo/searchFiles',
	        	                data:{
									fileName:encodeURI(valueSearch)
	        	                },
	        	                success :function(data){
	        	                	console.log(data);
	        	                	/* if(data!=null){ */
	  	        				     	 $(".defaultWindow").css({"display": "none", "z-index": 0});
		        				         $("#folder_win").css({"display": "none", "z-index": 0});
		        				         $("#file_win").css({"display": "none", "z-index": 0});
		        				         $(".kk").css({"display": "none", "z-index": 0});
		        				         $("#search_win").css({"display": "block", "z-index": 10});
	        	                		var str="";
		        	                	for(var key in data){
		        	                		str+='<ul class="top4_next_ul" style="display:block;">';
		        	                			str+='<p class="pStyle">'+key+'</p>';
	 	        	                		$.each(data[key],function(index,item){
			        	                		
	 	      				        		 str+='<li class="db_file">';
	 					        		 		str+='<input type="hidden" value='+item.id+'>';
	 					        		 		str+="<img src='${ctxStatic}/images/dbfile.png' alt=''/>";
	 					        		 		str+='<p>'+item.fileName+'</p>';
	 					        			 str+='</li>';
			        	                	})
			        	                	str+="</ul>";
		        	                	}
		        	                	var oDiv=$("#top4_next");
		        	                	oDiv.html(str);
		        	                	
										$('.db_file').contextMenu('myMenu3', {
			            					bindings: {
			            						'download':function (t) {//右键文件选择下载文件
		            		                		var download_fileId=$(t).children("input").val();
			            							var url = '/jrjw/a/documentmenu/documentMenuInfo/download';
		            		                		var form = $("<form>");
		            		                		form.attr("style","display:none");
		            		                		form.attr("target","");
		            		                		form.attr("method","post");
		            		                		form.attr("action",url);
		            		                		var input1 = $("<input>");
		            		                		input1.attr("type","hidden");
		            		                		input1.attr("name","fileId");
		            		                		input1.attr("value",download_fileId);
		            		                		$("body").append(form);
		            		                		form.append(input1);
		            		                		form.submit();
		            		                		form.remove();
			            						}
			           						 }
										}); 

	        	                	/* }else{
	        	                		return false;
	        	                	} */
	        	                },
	        	                error:function(){
	        	                	$.jBox.info("系统内部出错，请联系管理员！");
	        	                }
	                    	});
				       }else{
				    	   return false;
				       }     
				       });
			}

	        /*树形下拉菜单  */
	        treeMenu();
	        function treeMenu(){
		        $(".subNav").click(function () {
		            $(this).toggleClass("currentDd").siblings(".subNav").removeClass("currentDd");
		            $(this).toggleClass("currentDt").siblings(".subNav").removeClass("currentDt");
		            $(".kk").css({"display": "none", "z-index": 0});
		            // 修改数字控制速度， slideUp(500)控制卷起速度
		            $(this).next(".navContent").slideToggle(500).siblings(".navContent").slideUp(500);
		        })	
	        }
	        
        	/*点击返回  */
        	clickBack();
        	function clickBack(){
                $("#back").click(function () {

                	$("#modal1").css("display","none");
			        $("#opcity1").css("display","none");
                    $("#folder_win").css({"display": "block", "z-index": 10});
                    $("#file_win").css({"display": "none", "z-index": 0});
                    $("#search_win").css({"display": "none", "z-index": 0});
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
            <div class="nav" id="list1">
                <img src="${ctxStatic}/myhao/images/graphical.png" alt=""/>
            </div>
            <div class="nav" id="list2">
                <img src="${ctxStatic}/myhao/images/list.png" alt=""/>
            </div>
            <div id="search_box" class="nav">
                <div class="wrapper">
                    <input type="text" id="search" value="文件搜索" />
                    <button class="search_btn"><img src="${ctxStatic}/myhao/images/search_icon.png"/></button>
                </div>
            </div>
        </div>
    </div>
    <div id="food">
        <div id="tree" class="food_child">
			<div id="officeName"><p>处室部门列表</p></div>
            <div class="subNavBox">
            	<c:forEach items="${officeList }" var="office">
            		<div class="subNav" id="cw"><input type="hidden" value="${office.id} " id="department_name"/>${office.name}</div>
                 </c:forEach>
            </div>

            <!--树形右击菜单-->
            <div class="contextMenu" id="myMenu1">
                <ul>
                	<li id="rename"><img src="${ctxStatic}/myhao/images/rename.png"/>重命名</li>
                    <li id="delete_folder"><img src="${ctxStatic}/myhao/images/delete_folde.png"/>删除文件夹</li>
                </ul>
            </div>
            <div class="contextMenu" id="myMenu2">
                <ul>
                    <li id="delete_file"><img src="${ctxStatic}/myhao/images/delete_file.png"/>删除文件</li>
                    <li id="download"><img src="${ctxStatic}/myhao/images/upload_file.png"/>下载文件</li>
                </ul>
            </div>
            <div class="contextMenu" id="myMenu3">
                <ul>
                    <li id="download"><img src="${ctxStatic}/myhao/images/upload_file.png"/>下载文件</li>
                </ul>
            </div>
        </div>
        <!--右侧文件部门-->
        <div id="file" class="food_child">
        
        	<div class="defaultWindow">
                <div></div>
                <span class="ss">请选择您所在的部门</span>
            </div>
            <!--列表窗口-->
              <div class="kk">
                <div class="t">
                    <ul>
                        <li class="tLi1">文件名</li>
                        <li class="tLi2">文件大小</li>
                        <li class="tLi3">修改日期</li>
                    </ul>
                </div>
                <div class="l">
                    <div class="l1 ll">
                        <div class="lName">
                            <a href="javascript:void(0)">
                                <img src="${ctxStatic}/myhao/images/filet.png" alt=""/>
                            </a>
                            <a href="javascript:void(0)">独孤九剑</a>
                        </div>
                        <div class="lbs">1M</div>
                        <div class="lTime">2013.05.08</div>
                    </div>
                    <div class="l2 ll">
                        <div class="lName">
                            <a href="javascript:void(0)">
                                <img src="${ctxStatic}/myhao/images/filet.png" alt=""/>
                            </a>
                            <a href="javascript:void(0)">独孤九剑</a>
                        </div>
                        <div class="lbs">198M</div>
                        <div class="lTime">2013.05.08</div>
                    </div>
                    <div class="l3 ll">
                        <div class="lName">
                            <a href="javascript:void(0)">
                                <img src="${ctxStatic}/myhao/images/filet.png" alt=""/>
                            </a>
                            <a href="javascript:void(0)">独孤九剑</a>
                        </div>
                        <div class="lbs">566K</div>
                        <div class="lTime">2013.05.08</div>
                    </div>
                </div>
            </div>
            <!--文件夹窗口-->
            <div id="folder_win">
                <div class="top3">
                    <ul class="top3_ul">
                        <li>
                            <a href="javascript:void(0)" id="shareFiles">
                                <img src="${ctxStatic}/myhao/images/share.png" alt=""/>分享
                            </a>
                            <a href="javascript:void(0)" id="newfolder">
                                <img src="${ctxStatic}/myhao/images/New_File.png" alt=""/>新建文件夹
                            </a>
                        </li>
                    </ul>
                </div>
                <div id="departmentName"><p></p></div>
                <div id="top3_next">
                    <ul class="top3_next_ul" id="brunchFiles"></ul>
                </div>
                
            <!--文件分享遮罩层-->    
			<div id="modal">
			    <h3>分享文件夹</h3>
			    <span id=close>×</span>
				<div><button id="count">确认分享</button></div>
				<div id="list_list1"></div>
			</div>
			<div id="opcity"></div>
            </div>
            
            <!--文件窗口-->
            <div id="file_win">
                <!--表头-->
                <div class="top2">
                    <ul class="top2_ul">
                        <li>
                            <a href="javascript:void(0)" id="back">
                                <img src="${ctxStatic}/myhao/images/keyboard.png" alt=""/>返回
                            </a>
                        </li>
                        <li>
                            <a href="javascript:void(0)" id="add_files">
                                <img src="${ctxStatic}/images/file_upload.png" alt=""/>上传
                            </a>
                        </li>
                    </ul>
                </div>
                <div id="fileNames"><p></p></div>
                <!--内容部门-->
                <div id="top2_next">
                    <ul class="top2_next_ul" id="thirdLevel">
                    </ul>
                </div>
            </div>
            
            <div id="search_win">
                <!--表头-->
                <!--内容部门-->
                <div id="top4_next">
                	
                </div>
            </div>
            <!--上传窗口  -->
            <!--文件上传遮罩层-->    
			<div id="modal1">
			    <h3>文件上传</h3>
			    <span id=close1>×</span>
				<div id="list_list2"></div>
			</div>
			<div id="opcity1"></div>
        </div>
    </div>
</div>
</body>
</html>