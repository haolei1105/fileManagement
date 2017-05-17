package com.capinfo.jrjjg.modules.documentmenu.web;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.capinfo.jrjjg.common.config.Global;
import com.capinfo.jrjjg.common.mapper.JsonMapper;
import com.capinfo.jrjjg.common.utils.StringUtils;
import com.capinfo.jrjjg.common.web.BaseController;
import com.capinfo.jrjjg.modules.documentmenu.entity.DocuReturnTemplate;
import com.capinfo.jrjjg.modules.documentmenu.entity.DocumentMenuInfo;
import com.capinfo.jrjjg.modules.documentmenu.service.DocumentMenuInfoService;
import com.capinfo.jrjjg.modules.sys.utils.UserUtils;

/**
 * 文件共享菜单Controller
 * @author 王丹
 * @version 2017-02-17
 */
@Controller
@RequestMapping(value = "${adminPath}/documentmenu/documentMenuInfo")
public class DocumentMenuInfoController extends BaseController {

	@Autowired
	private DocumentMenuInfoService documentMenuInfoService;
	
	@ModelAttribute
	public DocumentMenuInfo get(@RequestParam(required=false) String id) {
		DocumentMenuInfo entity = null;
		if (StringUtils.isNotBlank(id)){
			entity = documentMenuInfoService.get(id);
		}
		if (entity == null){
			entity = new DocumentMenuInfo();
		}
		return entity;
	}
	
	
	@RequestMapping(value = {"list", ""})
	public String list( String upOrDown,String id,String preId,HttpServletRequest request, HttpServletResponse response, Model model) {
//		Page<DocumentMenuInfo> page = documentMenuInfoService.findPage(new Page<DocumentMenuInfo>(request, response), documentMenuInfo); 
//		model.addAttribute("page", page);
		
		response.setHeader("Pragma","No-cache"); 
		response.setHeader("Cache-Control","no-cache"); 
		response.setDateHeader("Expires", 0);  
		DocumentMenuInfo documentMenuInfo=new DocumentMenuInfo();
		documentMenuInfo.setParentId("0");
		List<String> officeIdList=documentMenuInfoService.findNameList(documentMenuInfo);
		documentMenuInfo.setParentId(null);
		List<Map<DocumentMenuInfo,List<DocumentMenuInfo>>> totalList=new ArrayList<Map<DocumentMenuInfo,List<DocumentMenuInfo>>>();
		//Map<DocumentMenuInfo,List<DocumentMenuInfo>> map=new HashMap<DocumentMenuInfo,List<DocumentMenuInfo>>();
		//List<String> idList=new ArrayList<String>();
		DocumentMenuInfo dmi=new DocumentMenuInfo();
		for (String string : officeIdList) {
			Map<DocumentMenuInfo,List<DocumentMenuInfo>> map=new HashMap<DocumentMenuInfo,List<DocumentMenuInfo>>();
			List<DocumentMenuInfo> list=new ArrayList<DocumentMenuInfo>();
			List<DocumentMenuInfo> menuList=documentMenuInfoService.findList(documentMenuInfo);
			for (DocumentMenuInfo documentMenuInfo2 : menuList) {
				if(null!=documentMenuInfo2.getParentId()&&documentMenuInfo2.getParentId()!=""){
					if(documentMenuInfo2.getParentId().equals(string)){
						list.add(documentMenuInfo2);
					}
				}
				if(documentMenuInfo2.getId().equals(string)){
					dmi=documentMenuInfo2;
				}
			}
			
			map.put(dmi, list);
			totalList.add(map);
		}
		if(null!=upOrDown&&upOrDown!=""&&id!=""&&null!=id&& preId!=""&&preId!=null){
			String haId=null;
			String hapreId=null;
			try {
				haId=URLDecoder.decode(id,"UTF-8");
				hapreId=URLDecoder.decode(preId,"UTF-8");
			} catch (UnsupportedEncodingException e) {
				
				e.printStackTrace();
			}
			for(int i=0;i<totalList.size();i++){
					Set<DocumentMenuInfo> set = totalList.get(i).keySet();
					Iterator<DocumentMenuInfo> iter = set.iterator();
					DocumentMenuInfo onlykey=new DocumentMenuInfo();
					while (iter.hasNext()) {
						DocumentMenuInfo key = (DocumentMenuInfo) iter.next();
						onlykey=key;
					}
					if(onlykey.getId().equals(haId.trim())){
						//Collections.swap(totalList,i-1,i);
						DocumentMenuInfo do1=documentMenuInfoService.get(haId.trim());
						String rankingId=do1.getRankingNo();
						DocumentMenuInfo do2=documentMenuInfoService.get(hapreId.trim());
						String anotherR=do2.getRankingNo();
						do1.setRankingNo(anotherR);
						do2.setRankingNo(rankingId);
						documentMenuInfoService.save(do1);
						documentMenuInfoService.save(do2);
					}
			}
		}
		
		model.addAttribute("totalList",totalList);
		return "modules/documentmenu/documentMenuInfoList";
	}

	@RequiresPermissions("documentmenu:documentMenuInfo:view")
	@RequestMapping(value = "form")
	public String form(DocumentMenuInfo documentMenuInfo, Model model) {
		model.addAttribute("documentMenuInfo", documentMenuInfo);
		return "modules/documentmenu/documentMenuInfoForm";
	}

	@RequiresPermissions("documentmenu:documentMenuInfo:edit")
	@RequestMapping(value = "save")
	public String save(DocumentMenuInfo documentMenuInfo, Model model, RedirectAttributes redirectAttributes) {
		try {
			String name=URLDecoder.decode(documentMenuInfo.getName(),"UTF-8");
			String parentId=URLDecoder.decode(documentMenuInfo.getParentId(),"UTF-8");
			String parentIds=URLDecoder.decode(documentMenuInfo.getParentIds(),"UTF-8");
			documentMenuInfo.setName(name.trim());
			documentMenuInfo.setParentId(parentId.trim());
			documentMenuInfo.setParentIds(parentIds);
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		if(documentMenuInfo.getParentId().equals("0")){
			DocumentMenuInfo dsk=new DocumentMenuInfo();
			dsk.setParentId("0");
			List<DocumentMenuInfo> list=documentMenuInfoService.findList(dsk);
			documentMenuInfo.setRankingNo(String.valueOf(list.size()));
		}
		documentMenuInfo.setOfficeId(UserUtils.getUser().getOffice().getId());
		documentMenuInfoService.save(documentMenuInfo);
		
		addMessage(redirectAttributes, "保存文件夹成功");
		return "redirect:"+Global.getAdminPath()+"/documentmenu/documentMenuInfo";
	}
	
	@RequiresPermissions("documentmenu:documentMenuInfo:edit")
	@RequestMapping(value = "delete")
	public String delete(String id, RedirectAttributes redirectAttributes) {
		//String str="yes";
		//Map<String,Object> result=new HashMap<String,Object>();
		DocumentMenuInfo documentMenuInfo=new DocumentMenuInfo();
		try {
			String deletId=URLDecoder.decode(id,"UTF-8");
			documentMenuInfo.setId(deletId.trim());
			documentMenuInfoService.delete(documentMenuInfo);
		} catch (Exception e) {
			//str="no";
			e.printStackTrace();
		}
		//result.put("result", str);
		return "redirect:"+Global.getAdminPath()+"/documentmenu/documentMenuInfo";
	}
	
	/**
	 * 查询第三级文件夹
	 * @param id
	 * @param redirectAttributes
	 * @param model
	 * @return
	 */
	@RequiresPermissions("documentmenu:documentMenuInfo:edit")
	@RequestMapping(value = "brunchFile")
	@ResponseBody
	public Map<String,List<DocumentMenuInfo>> brunchFile(String id, RedirectAttributes redirectAttributes,Model model) {
		Map<String,List<DocumentMenuInfo>> map=new HashMap<String,List<DocumentMenuInfo>>();
		String officeId=UserUtils.getUser().getOffice().getId();
		List<DocumentMenuInfo> list=documentMenuInfoService.brunchFileList(id);
		List<DocumentMenuInfo> limitedList=new ArrayList<DocumentMenuInfo>();
		if(null!=list&&list.size()>0){
			for (DocumentMenuInfo documentMenuInfo : list) {
				if(documentMenuInfo.getOfficeId().contains(officeId)){
					limitedList.add(documentMenuInfo);
				}
			}
		}
		map.put("limitedList", limitedList);
		return map;
	}
	
	/**
	 * 重命名
	 */
	@RequiresPermissions("documentmenu:documentMenuInfo:edit")
	@RequestMapping(value = "rename")
	@ResponseBody
	public Map<String,Object> rename(String id,String name, RedirectAttributes redirectAttributes) {
		String str="yes";
		Map<String,Object> result=new HashMap<String,Object>();
		try {
			String renameId=URLDecoder.decode(id,"UTF-8");
			DocumentMenuInfo documentMenuInfo=documentMenuInfoService.get(renameId.trim());
			String mingzi=URLDecoder.decode(name,"UTF-8");
			//documentMenuInfo.setId(renameId);
			documentMenuInfo.setName(mingzi);
			documentMenuInfoService.save(documentMenuInfo);
		} catch (Exception e) {
			str="no";
			e.printStackTrace();
		}
		result.put("result", str);
		return result;
	}
	
	
	@RequestMapping(value = "upload",method=RequestMethod.POST)
//	@ResponseBody
	public void upload(HttpServletRequest request,HttpServletResponse response,
			@RequestParam("id") String id,
            @RequestParam("file") MultipartFile file) {
		String resultFlag = "";
		String resultDesc = "";
//		Map<String,String> result=new HashMap<String,String>();
        //如果文件不为空，写入上传路径
		String filename =null;
		try {
        if(!file.isEmpty()) {
            //上传文件路径
			String path = request.getSession().getServletContext().getRealPath("/WEB-INF/upload");
            //上传文件名
            filename = file.getOriginalFilename();
            File filepath = new File(path,filename);
            //判断路径是否存在，如果不存在就创建一个
            if (!filepath.getParentFile().exists()) { 
                filepath.getParentFile().mkdirs();
            }
            //将上传文件保存到一个目标文件当中
			file.transferTo(new File(path + File.separator + filename));
			resultFlag = "yes";
			resultDesc = "上传成功";
        } else {
        	resultFlag = "no";
        	resultDesc = "文件为空！";
        }
		}catch (Exception e) {
			resultFlag = "error";
			resultDesc = "上传失败！";
			e.printStackTrace();
//			result.put("result", str);
			//return result;
		}
		DocumentMenuInfo documentMenuInfo=documentMenuInfoService.get(id);
		DocumentMenuInfo doc2=new DocumentMenuInfo();
		doc2.setName(filename);
		doc2.setParentId(id);
		doc2.setParentIds(id+","+documentMenuInfo.getParentId());
//		result.put("result", str);
		PrintWriter out = null;
		try {
			out = response.getWriter();
			DocuReturnTemplate template = new DocuReturnTemplate();
			template.setResultFlag(resultFlag);
			template.setResultDesc(resultDesc);
			String jsonStr = JsonMapper.getInstance().toJson(template);
			out.print(jsonStr);
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			out.flush();
			out.close();
		}
		/*
		DocuReturnTemplate template = new DocuReturnTemplate();
		template.setResultFlag(resultFlag);
		return template;
		*/
		
	}
	
	@RequestMapping(value = "test")
	public String test() {
		return "modules/documentmenu/laTest";
	}
	
	@RequestMapping(value = "download")
    @ResponseBody
	public void download(String name,String type,HttpServletRequest request,HttpServletResponse response) throws Exception {
         //ExcelAndCsvDownload.downLoadFile(moban.csv,csv,download, response);//依次传入需要下载的文件名，文件格式，路径，response参数
         String fileName = name;
         String fileType = type;
         String path=request.getSession().getServletContext().getRealPath("/WEB-INF/upload");
         File file = new File(path+"\\"+fileName+"."+fileType);  //根据文件路径获得File文件
         String allName=fileName+"."+fileType;

         BufferedInputStream bis = null;
         BufferedOutputStream bos = null;
         OutputStream fos = null;
         InputStream fis = null;
         try {
        	 fis = new FileInputStream(file);
             bis = new BufferedInputStream(fis);
             fos = response.getOutputStream();
             bos = new BufferedOutputStream(fos);
           //中文文件名支持
 	        String encodedfileName = null;
 	        String agent = request.getHeader("USER-AGENT");
 	        if(null != agent && -1 != agent.indexOf("MSIE")){//IE
 	            encodedfileName = java.net.URLEncoder.encode(allName,"UTF-8");
 	        }else if(null != agent && -1 != agent.indexOf("Mozilla")){
 	            encodedfileName = new String (allName.getBytes("UTF-8"),"iso-8859-1");
 	        }else{
 	            encodedfileName = java.net.URLEncoder.encode(allName,"UTF-8");
 	        }
 	        response.setHeader("Content-Disposition", "attachment; filename=\"" + encodedfileName + "\"");
             int byteRead = 0;
             byte[] buffer = new byte[8192];
             while((byteRead=bis.read(buffer,0,8192))!=-1){
                 bos.write(buffer,0,byteRead);
             }
             bos.flush();
             fis.close();
             bis.close();
             fos.close();
             bos.close();
         } catch (Exception e) {
        	 e.printStackTrace();   
         } 
	}
	
	@RequestMapping(value = "shareFiles")
    @ResponseBody
	public Map<String,Object> shareFiles(String folderId,String departmentId,HttpServletRequest request,HttpServletResponse response){
		Map<String,Object> result=new HashMap<String,Object>();
        String str="yes";
		try{
		String id=null;
		String deptId=null;
		if(null!=departmentId&&departmentId!=""&&folderId!=null&&folderId!=""){
        	 deptId=URLDecoder.decode(departmentId,"UTF-8");
        	 id=URLDecoder.decode(folderId,"UTF-8");
         }
		 DocumentMenuInfo doc=documentMenuInfoService.get(id.trim());
	         if(null!=doc){
	        	 String officeId=doc.getOfficeId();
	        	 doc.setOfficeId(officeId+","+deptId.trim());
	         }else{
	        	 str="no";
	         }
		}catch(Exception e){
			str="no";
			e.printStackTrace();
		}
         result.put("result", str);
         return result;
         
	}
	
	@RequestMapping(value = "searchFiles")
    @ResponseBody
	public Map<String,Object> searchFiles(DocumentMenuInfo documentMenuInfo,HttpServletRequest request,HttpServletResponse response){
		Map<String,Object> result=new HashMap<String,Object>();
        List<DocumentMenuInfo> list=null;
		
		if(null!=documentMenuInfo.getName()&&documentMenuInfo.getName()!=""){
			try {
				String name=URLDecoder.decode(documentMenuInfo.getName(), "UTF-8");
				documentMenuInfo.setName(name);
				list=documentMenuInfoService.search(documentMenuInfo);
			} catch (UnsupportedEncodingException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	     result.put("result", list);
	     return result;
	}
	
//	@RequestMapping(value = "deleteFiles")
//    @ResponseBody
//	public Map<String,Object> deleteFiles(DocumentMenuInfo documentMenuInfo,HttpServletRequest request,HttpServletResponse response){
//		
//	}
	
}