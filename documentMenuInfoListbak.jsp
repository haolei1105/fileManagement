<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page
	import="org.apache.shiro.web.filter.authc.FormAuthenticationFilter"%>
<%@ include file="/WEB-INF/views/include/taglib.jsp"%>
<html>
<head>
    <meta name="decorator" content="blank" />
    <meta http-equiv="pragma" content="no-cache"/>
    <meta http-equiv="cache-control" content="no-cache"/>
    <title>文件管理模块</title>
    <link type="text/css" rel="stylesheet" href="${ctxStatic}/myhao/css/reset.min.css"/>
    <link type="text/css" rel="stylesheet" href="${ctxStatic}/myhao/css/index.css"/>
    <script charset="UTF-8" type="text/javascript" src="${ctxStatic}/myhao/js/jquery1.7.2.js"></script>
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
									/*右键删除文件夹*/
									$('.db_folder').contextMenu('myMenu2', {//文件夹右击事件
		            					bindings: {
		            						'delete_folder': function (t) {
		            		                	var msg = "您真的确定要该文件夹吗？";
		            		                	if(confirm(msg)==true){//点击确定执行里面的代码
		            		                	var delete_folderId=$(t).children().first().val();
/* 		            		                		console.log(delete_folderId)
		            		                		console.log(startVal); */
		            			                	 $.ajax({
		            			     	                url:'/jrjw/a/documentmenu/documentMenuInfo/delete',
		            			     	                data:{
		            			     	                	departmentId:startVal,//部门ID
		            			     	                	folderId:delete_folderId//删除的文件夹ID
		            			     	                },
		            			     	               success: function (aa) {
		            			     	            	  $(t).remove();
		            			  						  alert("删除成功");
		            			   	                }
		            			     			 }); 
		            		                    }else{
		            		                        return false;
		            		                    }
		            						}
		           						 }
									});
								    
									
									/*双击文件夹，进入该文件内  */
									/* var folderId=""; */
									 $(".db_folder").children("img").each(function(index,item){//循环文件夹 图片
										 $(this).dblclick(function(){//双击该文件夹图片
											 folderId = $(this).parent().children().first().val();//变量保存文件夹下的隐藏域的value（ID）值；
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
																$('.db_file').contextMenu('myMenu3', {
									            					bindings: {
									            						'delete_file': function (t) {//右键文件选择删除文件
									            		                	var msg = "您真的确定要该文件吗？";
									            		                	if(confirm(msg)==true){
									            		                		var delete_fileId=$(t).children("input").val();
									            			                	$.ajax({
									            			     	                url:'/jrjw/a/documentmenu/documentMenuInfo/delete',
									            			     	                data:{
									            			     	                	id:delete_fileId//将要删除的文件ID
									            			     	                },
									            			     	               success: function (aa) {
									            			     	            	  $(t).remove()
									            			   	                      alert("删除成功");
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
									            		                		var fileExt=(/[.]/.exec(filename)) ? /[^.]+$/.exec(filename.toLowerCase()) : '';//后缀名
									            		                		/* alert(fileExt); */
									            			                	$.ajax({
									            			     	                url:'/jrjw/a/documentmenu/documentMenuInfo/download',
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
						        	 $("#modal1").css("display","none");
				        			 $("#opcity1").css("display","none");
				        			 $("#list_list2").html("");
						        	alert("上传成功！");
						         }/* else if(data.resultFlag=='no'){
						        	 $("#modal1").css("display","none");
							         $("#opcity1").css("display","none");
						        	alert("文件为空！");
						         } */else if(data.resultFlag=='no'){
						        	 $("#modal1").css("display","none");
							         $("#opcity1").css("display","none");
							         $("#list_list2").html("");
						        	alert("上传失败！");
						         }
						     }
					    });
				    }else{
				    	alert("上传文件不能为空");
				    	return	false;
				    }
				});
        });
		}
		    /*文件夹分享  */
		    fx();
		    function fx(){
		    	/*分享那个文件夹*/
		    	var wjjId="";
				 $("#new_folder").click(function(){
			    	 $(".db_folder").each(function(){//判断文件夹点击选中，IE不识别rgb
 						 if($(this).css("background-color")=="rgb(204, 235, 248)"||$(this).css("background-color")=="#ccebf8"||$(this).css("border-color")=="#128ddd"){
							 wjjId+=$(this).children().first().val();//变量拼接该文件夹的ID值
								 wjjId+=",";//拼接逗号
						 }
					 });
					 if(wjjId!=""){//确认有文件夹被选中，变量的内容不为空
				         $("#modal").css("display","block");
				         $("#opcity").css("display","block");
						 $(".subNav").each(function(index,tiem){
							 var bmName=$(this).text();
							 var oliId=$(this).children().first().val();
							 var olis=document.createElement("li");
		 					 var oInputs=document.createElement("input");
		 					 var oDiv=$("#list_list1");
					         $(oInputs).attr({
					                "type":"checkbox",
					                "name": "test",
					                "class":"btnture"
					             });
					         var oUl=$("#modal");
					         var oInputId=document.createElement("input");
					         $(oInputId).attr(
					        	 "type","hidden"
					         )
					         $(oInputId).val(oliId);
					         $(olis).append(oInputId);
					         $(olis).append(oInputs);
					         $(olis).append(bmName);
					         $(oDiv).append($(olis));
					         oUl.append($(oDiv));
						 });
						 $("#close").click(function(){
					         $("#modal").css("display","none");
					         $("#opcity").css("display","none");
					         wjjId="";
					         $("#list_list1").html("");
						 });
					 }else{
						 alert("分享文件夹不能为空");
					 }
				 });
				 $("#count").click(function(){
					 var newwjjId=wjjId.substring(0,wjjId.length-1);//去掉变量的字符串最后一个逗号，并保存到新的变量中；
					 var searchId="";
					 $(".btnture").each(function(){
						 if($(this).prop("checked")==true){//如果分享部门前复选框被选中；
							/*  console.log("2"); */
							 searchId+=$(this).prevAll("input").first().val()/* .trim() IE8不支持删除字符串里所有空格*/;//获取该部门的下第一个隐藏域的ID值；
							 searchId+=",";//给变量拼接逗号；
						 }
					 });
					 var newsearchId=searchId.substring(0,searchId.length-1);//去除变量的最后一个逗号，并且保存到新的变量里；
/* 					 console.log(newwjjId)
					 console.log(newsearchId) */
					 if(searchId!=""&&wjjId!=""){
						 $.ajax({
				                url:'/jrjw/a/documentmenu/documentMenuInfo/shareFiles',
				                data:{
				                	folderId:encodeURI(newwjjId),//文件夹的ID
									departmentId:encodeURI(newsearchId)//分享到的部门ID
				                },
				                success: function (returndata) {
				                	 if(returndata.result=='yes'){
				                		 alert("分享成功！");
								         $("#modal").css("display","none");
								         $("#opcity").css("display","none");
								         wjjId="";
								         $("#list_list1").html("");
				                	 }else{
				                		 alert("分享失败！");
								         $("#modal").css("display","none  ");
								         $("#opcity").css("display","none");
								         wjjId="";
								         $("#list_list1").html("");
				                	 }
				                	 /*问题同时分享2个文件夹   返回失败  */
						        }
						 }); 
					 }else{
						 alert("分享部门不能为空");
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
		    });
		    $("#list2").click(function(){
		    	$(this).css("display","none");
		    	$("#list1").css("display","block");
		    	$(".kk").css({"display": "none", "z-index": 0});
		    	$("#folder_win").css({"display": "none", "z-index": 0});
	            $("#file_win").css({"display": "block", "z-index": 10});
		    })
		    /*所搜 功能 */
		    searchInput();
		    function searchInput(){
		    	 var curSearch = $("#search");
		    	 	curSearch.click(function(){
		    	 		 $(this).focus();
		    	 		if ($(this).val() != "") {
				            $(this).val("");
				        }
		    	 	 })
		            $(document).bind("click",function(e){    
		                if($(e.target).closest(".wrapper").length == 0){
		                //点击wrapper之外就则触发
		                  curSearch.val("文件搜索")
		                }
		            })
				    curSearch.keyup(function(e) {
				    	var valueSearch=$(this).val();
				       if(e.keyCode  == 13 && $(this).val()!=""&&$(this).val()!="文件搜索") {
 				    	   $.ajax({
	        	                url:'/jrjw/a/documentmenu/documentMenuInfo/searchFiles',
	        	                data:{
									name:encodeURI(valueSearch)
	        	                },
	        	                success :function(aa){
	 								if(aa.result && aa.result.length>0){
	 									curSearch.val("文件搜索");
	  	        				     	 $(".defaultWindow").css({"display": "none", "z-index": 0});
		        				         $("#folder_win").css({"display": "none", "z-index": 0});
		        				         $("#file_win").css({"display": "block", "z-index": 10});
		        				         $(".kk").css({"display": "none", "z-index": 0});
		        				         $("#thirdLevel").children().remove();
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
				            			     	            	  $(t).remove()
				            			     	            	  alert("删除成功")
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
				            			     	                url:'/jrjw/a/documentmenu/documentMenuInfo/download',
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
	 									$(curSearch).val("文件搜索");
	 								}
	        				         
	        	                },
	        	                error:function(){
	        	                	alert("系统内部出错，请联系管理员");
	        	                }
	                    	});
				       }else{
				    	   return false;
				       }     
				       });
 				    $(".search_btn").click(function(){
				    	if(curSearch.val()!=""&&curSearch.val()!="文件搜索"){
				    		var valueSearch=curSearch.val();
				    		  $.ajax({
		        	                url:'/jrjw/a/documentmenu/documentMenuInfo/searchFiles',
		        	                data:{
										name:encodeURI(valueSearch)		
		        	                },
		        	                success :function(aa){
		 								if(aa.result && aa.result.length>0){
		 									$(curSearch).val("文件搜索");
			        				         $(".defaultWindow").css({"display": "none", "z-index": 0});
			        				         $("#folder_win").css({"display": "none", "z-index": 0});
			        				         $("#file_win").css({"display": "block", "z-index": 0});
			        				         $("#thirdLevel").children().remove();
		 									for (var i = 0; i <aa.result.length; i++) {
					                			var div="<li class='db_file'>"+
				                            	"<img src='${ctxStatic}/images/dbfile.png' alt=''/>"+
				                            	"<p>"+aa.result[i].name+"</p>"+
				                            	"</li>";
				                            	$("#thirdLevel").append(div);
					                		}
		 									$(".db_file").each(function(){
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
					            			     	            	  $(t).remove()
					            			     	            	  alert("删除成功")
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
					            			     	                url:'/jrjw/a/documentmenu/documentMenuInfo/download',
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
		 									$(curSearch).val("文件搜索");
		 								}
		        	                },
		        	                error:function(){
		        	                	alert("系统内部出错，请联系管理员");
		        	                }
		                    	});
					       }else{
					    	   $(curSearch).val("文件搜索");
					    	   return false;
					       }     
					       });
				    	}
		    
		    /* 添加部门 */
		    addDepartment();
			function addDepartment(){
				$("#add_menu").click(function () {
				    var isChrome = window.navigator.userAgent.indexOf("Chrome") !== -1;
				    if (isChrome) {
				        /* alert("是Chrome浏览器"); */
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
		            $(".kk").css({"display": "none", "z-index": 0});
		            // 修改数字控制速度， slideUp(500)控制卷起速度
		            $(this).next(".navContent").slideToggle(500).siblings(".navContent").slideUp(500);
		        })	
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
						    	/* alert("谷歌浏览器"); */
			                	var msg = "您真的确定修改该部门名称吗？";
			                	if(confirm(msg)==true){
				                	var flgText =$(t).text();
									var flg=$(t).children();
									var flgVal=flg.val();
 				                    	$(t).text("");
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
		                	var msg = "您确定要删除该部门吗？";
		                	if(confirm(msg)==true){
			                	var deleteVal=$(t).children().val();
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
							    	/* alert("谷歌浏览器"); */
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

                	$("#modal1").css("display","none");
			        $("#opcity1").css("display","none");
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
                    <li>
	                    <a href="#">
		                    <input type="hidden" value="${menu.id}" id="file_name" class="file_name"/>
		                    <img src="${ctxStatic}/myhao/images/sfolder.png" alt=""/>${menu.name}
	                    </a>
                    </li>
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
                <span class="ss">请选择您所在的部门,如部门不存在请点击"添加部门"</span>
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
                
            <!--文件分享遮罩层-->    
            <div class="container"></div>
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
            <!--文件上传遮罩层-->    
            <div class="container1"></div>
			<div id="modal1">
			    <h3>文件上传</h3>
			    <span id=close1>×</span>
				<div id="list_list2">
<!-- 					      <form id= "uploadForm" enctype="multipart/form-data">  
				          <input type="hidden" name="id"/>  
				          <input type="file" name="file" id="fileId"/>
				          <input type="button" value="确认上传" id="btnsubmit"/>  
    					</form> -->
				</div>
			</div>
			<div id="opcity1"></div>
			
			<!--右键删除文件夹  -->
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