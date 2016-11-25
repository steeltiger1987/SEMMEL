package com.report.env
{
	import com.hurlant.crypto.*;
	import com.hurlant.crypto.hash.SHA1;
	import com.hurlant.crypto.symmetric.*;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	import com.report.*;
	import com.security.util.*;
	import com.semmel.*;
	
	import de.polygonal.ds.HashMap;
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	
	public class EnvReportController extends Sprite
	{
		
		//download file function 
		var loadedSize:Number = 0;
		var theAFileSize:Number= 0;
		private var fileDownload:File;
		private var fileDownloadTemp:File;
		private var fileStream:FileStream = new FileStream;
		
		private var stream:URLStream;
		private var ioError:Boolean = false;
		
		private var sponImage:String = "";
		
		public static const DOWNLOADED_EVENT:String = "Downloaded_Event";
		public static const CHECKUPDATE_EVENT:String = "CheckUpdate_Event";
		
		public var returnData:String = "";
		
		public function EnvReportController()
		{
			initConfig();
		}
		
		
		public function doFetchData():void{
		
			//Core.doConfig("http://www.google.com");
			
			
			//trace("Core: " + Core.url_mapi);

		}
		
		public function doCheckUpdate(licenseKey:String):void{
			
			//aa5c4f1abc0361b9 66df0f1c22f41e56843673ef
			//key: aa5c4f1abc0361b9
			
			trace("check update: " + licenseKey);
			
			var urlreq:URLRequest = new URLRequest (Constants.url_envapi);
			urlreq.method = URLRequestMethod.POST; 
			
			var urlvars:URLVariables = new URLVariables(); 
			urlvars.act = "doCheck";
			//urlvars.contentType = "application/x-www-form-urlencoded";
			urlvars.license = licenseKey;
			urlreq.data = urlvars;          
			
			var loader:URLLoader = new URLLoader (urlreq); 
			loader.addEventListener(Event.COMPLETE, doPostComplete); 
			//loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.load(urlreq); 
			
		}

		private function doPostComplete (event:Event):void{
			//var variables:URLVariables = new URLVariables( event.target.data );
			trace("dopost complete: " + event.target.data);
			this.returnData = event.target.data;
			//resptxt.text = variables.done;
			//dispatchEvent(new Event(CHECKUPDATE_EVENT, false, this.returnData));
			dispatchEvent(new Event(CHECKUPDATE_EVENT));
		}
		
		public function initDownload(targetFilename:String):void{
			
			trace("INIT DOWNLOAD FILE: " + targetFilename);
			
			fileDownload = File.applicationStorageDirectory.resolvePath(targetFilename);
			fileDownloadTemp = File.applicationStorageDirectory.resolvePath(targetFilename + ".tmp");
			
			var header0:URLRequestHeader=null;
			
		//	var req:URLRequest = new URLRequest(Constants.url_mapi.replace("mapi","images/") + strFileName + "?rnd="+ String(Math.round(Math.random() * (9999999 - 0) + 0)));
			
			var req:URLRequest = new URLRequest(Constants.url_envapi+"?rnd="+ String(Math.round(Math.random() * (9999999 - 0) + 0)));
			
			
			req.method = URLRequestMethod.POST;
			req.contentType = "application/x-www-form-urlencoded";
			req.data = "act=doFetch&filename="+targetFilename+"&hid="+Constants.getHospitalId();
			
			stream = new URLStream();
			stream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			stream.addEventListener(ProgressEvent.PROGRESS, writeFile);
			stream.addEventListener(Event.COMPLETE, completeDownloadFile);
			
			stream.load(req);
			
			fileStream.open(fileDownloadTemp, fileDownload.exists ? FileMode.WRITE:FileMode.WRITE);
		}
		
		
		private function completeDownloadFile(evt:Event):void {
			fileStream.close();
			trace("Download Complete");
			
			fileDownloadTemp.copyTo(fileDownload, true);
			
			fileDownloadTemp.deleteFile();
			
			//must need a Sprite3
			dispatchEvent(new Event(DOWNLOADED_EVENT));
		}
		
		private function writeFile(event:ProgressEvent):void {
			trace("Downloading... " + (((loadedSize+event.bytesLoaded)/event.bytesTotal)*100).toFixed(0)+ "%");
			
			// chunk of new data
			var fileDataChunk:ByteArray = new ByteArray();
			// read bytes from the internet using URLStream
			stream.readBytes(fileDataChunk,0,stream.bytesAvailable);
			// write bytes to the disk using FileStream
			fileStream.writeBytes(fileDataChunk,0,fileDataChunk.length);
		}
		
		protected function onIOError(e:IOErrorEvent):void
		{
			ioError = true;
			trace(e);
			//isLoaded = true;
		}
		
		
		//in-memory calculation
		
		private var raw:String = "";
		
		private function initConfig():void{
			trace("RUN INIT CONFIG()");
			//var fn:String = "report_111_env_201512.shard"; //data file / result file
			var fn:String = "config_" + Constants.getHospitalId() + "_env.data"; //env config file value
			
			var file:File = null;
			file = File.applicationStorageDirectory.resolvePath(fn);
			
			if(file.exists && file.size!=0){
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				raw = stream.readUTFBytes(stream.bytesAvailable).toString(); //legnth 16 only
				stream.close();
			
				var jsonConfig:Object = JSON.parse(AESCrypto.decrypt(raw, Constants.getLicenseKey().substring(0,16)));
				
				EnvDataDictionary.setCategory(new ArrayCollection(jsonConfig["category"]));
				EnvDataDictionary.setArea(new ArrayCollection(jsonConfig["formTemplate"]));
				trace("jsonConfig formTemplate: " + jsonConfig["formTemplate"]);
				
				EnvDataDictionary.setDeficiencyNote(new ArrayCollection(jsonConfig["deficiencyNote"]));
				EnvDataDictionary.setItem(new ArrayCollection(jsonConfig["item"]));
				EnvDataDictionary.setDepartment(new ArrayCollection(jsonConfig["department"]));
				
				EnvDataDictionary.getMethod();
				
			}
			//calculation
			//1st graph - compliance by area!
			
			//config values!!!!
			//decrypt: {"category":[{"cat_id":7,"category":"Category A"},{"cat_id":8,"category":"Category B"},{"cat_id":9,"category":"Category C"}],
			//"item":[{"item_id":8,"item":"Item A","hosp_id":111},
			//{"item_id":9,"item":"Item B","hosp_id":111},{"item_id":10,"item":"Item C","hosp_id":111},{"item_id":11,"item":"Item D","hosp_id":111},
			//{"item_id":12,"item":"Item E","hosp_id":111}],"department":[{"dept_id":711,"dept_name":"ICU"},{"dept_id":712,"dept_name":"Medical Ward"}],
			//"deficiencyNote":[{"nid":5,"note":"Note A"},{"nid":6,"note":"Note B"},{"nid":7,"note":"Note C"}],
			//"formTemplate":[{"form_id":6,"title":"Area A"},{"form_id":7,"title":"Area B"}]}
			
			
		}
		
		public function doAnalyticAuditCountByArea(yyyy:String):ArrayCollection{
			
			var acAnalytic:ArrayCollection = new ArrayCollection();
			var fn:String = "";
			var file:File = null;
			
			for each(var area:Object in EnvDataDictionary.getArea()){
				trace("area object loop: " + area.form_id + ", " + area.title);
				//loop thru 12 month
				//count by Area FormID - if match
			
				var obj:Object = new Object();
				obj.area = area.title;
				obj.jan=0;
				obj.feb=0;
				obj.mar=0;
				obj.apr=0;
				obj.may=0;
				obj.jun=0;
				obj.jul=0;
				obj.aug=0;
				obj.sep=0;
				obj.oct=0;
				obj.nov=0;
				obj.dec=0;
				

				for(var month:Number=1; month<=12; month++){
					
					fn = "report_"+Constants.getHospitalId()+"_env_"+yyyy+String(month)+".shard"; //data file / result file
					file = File.applicationStorageDirectory.resolvePath(fn);
					
					if(file.exists){
						var stream:FileStream = new FileStream();
						stream.open(file, FileMode.READ);
						raw = stream.readUTFBytes(stream.bytesAvailable).toString(); //legnth 16 only
						stream.close();
						
						var jsonData:Object = JSON.parse(AESCrypto.decrypt(raw, Constants.getLicenseKey().substring(0,16)));
						
						var acForm:ArrayCollection = new ArrayCollection(jsonData["lstEnvResultsForm"]);
						
						for each(var form:Object in acForm){
							if(form.form_id==area.form_id){ //0 is compliance
								switch(month){
									case 1:
										obj.jan++;
										break;
									case 2:
										obj.feb++;
										break;
									case 3:
										obj.mar++;
										break;
									case 4:
										obj.apr++;
										break;
									case 5:
										obj.may++;
										break;
									case 6:
										obj.jun++;
										break;
									case 7:
										obj.jul++;
										break;
									case 8:
										obj.aug++;
										break;
									case 9:
										obj.sep++;
										break;
									case 10:
										obj.oct++;
										break;
									case 11:
										obj.nov++;
										break;
									case 12:
										obj.dec++;
										break;
								}
							}
						}
					}
				}
				acAnalytic.addItem(obj);
			}
			//decrypt: {"lstEnvResultsForm":[{"id":11,"form_id":6,"dept_id":711,"status":0,"uid":235,"hid":111,"
			//startdatetime":"Dec 22, 2015","enddatetime":"Dec 22, 2015","createddate":"Dec 22, 2015"}],
			//"lstEnvResults":[{"id":28,"rid":11,"catid":7,"itemid":8,"method":1,"result":0,"note":"user enter note","nid":0,
			//"temp_id":"","prod_id":"","hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"},
			//{"id":29,"rid":11,"catid":8,"itemid":9,"method":2,"result":0,"note":"","nid":5,"temp_id":"","prod_id":"",
			//"hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"},
			//{"id":30,"rid":11,"catid":9,"itemid":10,"method":3,"result":2,"note":"for method 3 and 4","nid":0,"temp_id":"ABC123","prod_id":"WP543213930","hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"}]}
			
			return acAnalytic;
		}
		
		
		public function doAnalyticAuditCountByWardFacility(yyyy:String):ArrayCollection{
			
			var acAnalytic:ArrayCollection = new ArrayCollection();
			var fn:String = "";
			var file:File = null;
			
			for each(var wardFacility:Object in EnvDataDictionary.getDepartment()){
				trace("ward/facility object loop: " + wardFacility.dept_id + ", " + wardFacility.dept_name);
				//loop thru 12 month
				//count by Area FormID - if match
				
				var obj:Object = new Object();
				obj.wardFacility = wardFacility.dept_name;
				obj.jan=0;
				obj.feb=0;
				obj.mar=0;
				obj.apr=0;
				obj.may=0;
				obj.jun=0;
				obj.jul=0;
				obj.aug=0;
				obj.sep=0;
				obj.oct=0;
				obj.nov=0;
				obj.dec=0;
				
				
				for(var month:Number=1; month<=12; month++){
					
					fn = "report_"+Constants.getHospitalId()+"_env_"+yyyy+String(month)+".shard"; //data file / result file
					file = File.applicationStorageDirectory.resolvePath(fn);
					
					if(file.exists){
						var stream:FileStream = new FileStream();
						stream.open(file, FileMode.READ);
						raw = stream.readUTFBytes(stream.bytesAvailable).toString(); //legnth 16 only
						stream.close();
						
						var jsonData:Object = JSON.parse(AESCrypto.decrypt(raw, Constants.getLicenseKey().substring(0,16)));
						
						var acForm:ArrayCollection = new ArrayCollection(jsonData["lstEnvResultsForm"]);
						
						for each(var form:Object in acForm){
							if(form.dept_id==wardFacility.dept_id){ //0 is compliance
								switch(month){
									case 1:
										obj.jan++;
										break;
									case 2:
										obj.feb++;
										break;
									case 3:
										obj.mar++;
										break;
									case 4:
										obj.apr++;
										break;
									case 5:
										obj.may++;
										break;
									case 6:
										obj.jun++;
										break;
									case 7:
										obj.jul++;
										break;
									case 8:
										obj.aug++;
										break;
									case 9:
										obj.sep++;
										break;
									case 10:
										obj.oct++;
										break;
									case 11:
										obj.nov++;
										break;
									case 12:
										obj.dec++;
										break;
								}
							}
						}
					}
				}
				acAnalytic.addItem(obj);
			}
			//decrypt: {"lstEnvResultsForm":[{"id":11,"form_id":6,"dept_id":711,"status":0,"uid":235,"hid":111,"
			//startdatetime":"Dec 22, 2015","enddatetime":"Dec 22, 2015","createddate":"Dec 22, 2015"}],
			//"lstEnvResults":[{"id":28,"rid":11,"catid":7,"itemid":8,"method":1,"result":0,"note":"user enter note","nid":0,
			//"temp_id":"","prod_id":"","hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"},
			//{"id":29,"rid":11,"catid":8,"itemid":9,"method":2,"result":0,"note":"","nid":5,"temp_id":"","prod_id":"",
			//"hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"},
			//{"id":30,"rid":11,"catid":9,"itemid":10,"method":3,"result":2,"note":"for method 3 and 4","nid":0,"temp_id":"ABC123","prod_id":"WP543213930","hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"}]}
			
			return acAnalytic;
		}
		
		
		public function doAnalyticOverallComplianceByYearMonth(yyyyMM:String):Object{
			var obj:Object = new Object();
			
			var fn:String = "report_"+Constants.getHospitalId()+"_env_"+yyyyMM+".shard"; //data file / result file
			//var fn:String = "config_111_env.data"; //env config file value
			
			var yyyy:String = yyyyMM.substr(0, 4);
			var mm:String = yyyyMM.substr(4);
			
			obj.monthYear = Util.getShortMonthName(mm)+", " + yyyy;
			
			var file:File = null;
			file = File.applicationStorageDirectory.resolvePath(fn);
			if(file.exists){
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				raw = stream.readUTFBytes(stream.bytesAvailable).toString(); //legnth 16 only
				stream.close();
				
				var jsonData:Object = JSON.parse(AESCrypto.decrypt(raw, Constants.getLicenseKey().substring(0,16)));
				
				var acResults:ArrayCollection = new ArrayCollection(jsonData["lstEnvResults"]);
				
				for each(var result:Object in acResults){
					obj.ttl++;
					if(result.result==0){ //0 is compliance
						obj.cnt++;
					}
				}
				
				obj.pect = Util.doCalcPercentage(obj.cnt, obj.ttl);
				
			}
			
			return obj;
		}
		
		
		public function doAnalyticComplianceByWardFacility(yyyyMM:String, domain:String=null, filterKey:String=null):ArrayCollection{
			var acAnalytic:ArrayCollection = new ArrayCollection();
			
			var fn:String = "report_"+Constants.getHospitalId()+"_env_"+yyyyMM+".shard"; //data file / result file
			trace("fn: " + fn);
			var file:File = null;
			file = File.applicationStorageDirectory.resolvePath(fn);
			if(file.exists){
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				raw = stream.readUTFBytes(stream.bytesAvailable).toString(); //legnth 16 only
				stream.close();
				
				var jsonData:Object = JSON.parse(AESCrypto.decrypt(raw, Constants.getLicenseKey().substring(0,16)));
				
				var acForm:ArrayCollection = new ArrayCollection(jsonData["lstEnvResultsForm"]);
				var acResults:ArrayCollection = new ArrayCollection(jsonData["lstEnvResults"]);
				
				trace("acResults: " + acResults.length);
				
				var hm:HashMap = new HashMap();
				
				var acCompWardFacilityData:Object = null;
				
				if(domain==null){
					var objOverall:Object  = doComplianceOverall(acResults);
					objOverall.deptId = "-1";
					objOverall.dept = "Overall Compliance";
					acAnalytic.addItem(objOverall);
				}
				
				
				
				for each(var area:Object in acForm){
					
					if(domain!=null){
						if(domain==Constants.DOMAIN_ENV_AREA){
							if(area.form_id!=filterKey){
								continue;
							}
						}
					}
					
					if(!hm.hasKey(area.dept_id)){
						acCompWardFacilityData = new Object();
						acCompWardFacilityData.deptId = area.dept_id
						acCompWardFacilityData.dept = EnvDataDictionary.getDepartmentById(area.dept_id);
						
						//acCompWardFacilityData.cnt = 0;
						//acCompWardFacilityData.ttl = 0;
						
						//for each(var area:Object in acForm){
							
						
						
								//calculate the env results for the counts...
								//var result:Object = doCompliacenByArea(area.id, acResults);
								//var result:Object = doComplianceByWardFacility(area.id, acResults);
								//var result:Object = doComplianceByWardFacility(area.id, acResults, domain, filterKey);
								var result:Object = doComplianceByWardFacility(area.id, acResults, domain, filterKey);
								trace("ac form id: " + area.id);
								acCompWardFacilityData.cnt = result.cnt;
								acCompWardFacilityData.ttl = result.ttl;
								
							
						//}
						
						hm.set(area.dept_id, acCompWardFacilityData);
						acAnalytic.addItem(acCompWardFacilityData);
						
					} else {
					
						acCompWardFacilityData = hm.get(area.dept_id);
						//for each(var area:Object in acForm){
							
						trace("ac form id: " + area.id);
								//var result:Object = doComplianceByWardFacility(area.id, acResults, domain, filterKey);
								var result:Object = doComplianceByWardFacility(area.id, acResults, domain, filterKey);
								acCompWardFacilityData.cnt += result.cnt;
								acCompWardFacilityData.ttl += result.ttl;
								//trace("result cnt " + result.cnt + " ttl " + result.ttl);
							
						//}
						
					}
				}
				
				
				for each(var act:Object in acAnalytic){
					act.pect = Util.doCalcPercentage(act.cnt, act.ttl);
					trace(act.dept + " = " + act.pect);
				}
				
				//decrypt: {"lstEnvResultsForm":[{"id":11,"form_id":6,"dept_id":711,"status":0,"uid":235,"hid":111,"
				//startdatetime":"Dec 22, 2015","enddatetime":"Dec 22, 2015","createddate":"Dec 22, 2015"}],
				//"lstEnvResults":[{"id":28,"rid":11,"catid":7,"itemid":8,"method":1,"result":0,"note":"user enter note","nid":0,
				//"temp_id":"","prod_id":"","hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"},
				//{"id":29,"rid":11,"catid":8,"itemid":9,"method":2,"result":0,"note":"","nid":5,"temp_id":"","prod_id":"",
				//"hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"},
				//{"id":30,"rid":11,"catid":9,"itemid":10,"method":3,"result":2,"note":"for method 3 and 4","nid":0,"temp_id":"ABC123","prod_id":"WP543213930","hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"}]}
				
			}
			return acAnalytic;
		}
		
		public function doAnalyticComplianceByArea(yyyyMM:String, domain:String=null, filterKey:String=null):ArrayCollection{
			var acAnalytic:ArrayCollection = new ArrayCollection();
			var fn:String = "report_"+Constants.getHospitalId()+"_env_"+yyyyMM+".shard"; //data file / result file
			//var fn:String = "config_111_env.data"; //env config file value
			
			var file:File = null;
			file = File.applicationStorageDirectory.resolvePath(fn);
			if(file.exists){
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				raw = stream.readUTFBytes(stream.bytesAvailable).toString(); //legnth 16 only
				stream.close();
				
				var jsonData:Object = JSON.parse(AESCrypto.decrypt(raw, Constants.getLicenseKey().substring(0,16)));
				
				var acForm:ArrayCollection = new ArrayCollection(jsonData["lstEnvResultsForm"]);
				var acResults:ArrayCollection = new ArrayCollection(jsonData["lstEnvResults"]);
				
				var acCompArea:ArrayCollection = new ArrayCollection();
				var hm:HashMap = new HashMap();
				
				var acCompAreaData:Object = null;
				
				if(domain==null){
					var objOverall:Object  = doComplianceOverall(acResults);
					objOverall.areaId = "-1";
					objOverall.area = "Overall Compliance";
					acAnalytic.addItem(objOverall);
				}
				
				var refIds:Array = new Array();
				trace("domain: " + domain + ", " + filterKey);
				if(domain!=null){
					if(domain==Constants.DOMAIN_ENV_WARDFACILITY){
						refIds = doGetRefIdByWardFacilityId(filterKey, acForm); 
					}
				}
				
				
				for each(var area:Object in acForm){
					
					if(domain!=null){
						trace("domain is not null");
						if(domain==Constants.DOMAIN_ENV_WARDFACILITY){
							trace("domain is ward facility");
							trace("dept " + area.dept_id + ", vs filterKey: " + filterKey);
							if(area.dept_id!=filterKey){
								continue;
							}
						} 
					}
					
					trace("area.form_id " + area.form_id);
					
					if(!hm.hasKey(area.form_id)){
						acCompAreaData = new Object();
						acCompAreaData.areaId = area.form_id;
						acCompAreaData.area = EnvDataDictionary.getAreaById(area.form_id);
						
						//calculate the env results for the counts...
						//var result:Object = doCompliacenByArea(area.id, acResults);
						var result:Object = doCompliacenByArea(area.id, acResults, domain, filterKey); //logic to add filter
						acCompAreaData.cnt = result.cnt;
						acCompAreaData.ttl = result.ttl;
						
						hm.set(area.form_id, acCompAreaData);
						acAnalytic.addItem(acCompAreaData);
						//TODO: calculation here...
						
					} else {
						
						acCompAreaData = hm.get(area.form_id);
						//calculate the env results for the counts...
						var result:Object = doCompliacenByArea(area.id, acResults);
						acCompAreaData.cnt += result.cnt;
						acCompAreaData.ttl += result.ttl;
						
					}
				}
				
				//in PECT!
				
				
				
				trace("loop thru acAnalytics: " + String(acAnalytic.length));
				//var objPrint:Object = null;
				//for(var x:Number = 0; x < acAnalytic.length; x++){
					//objPrint = acAnalytic.getItemAt(x);
					//trace("obj: " + objPrint);
					//trace("are: " + objPrint.areaId + ", " + objPrint.area + ", " + objPrint.cnt + ", " + objPrint.ttl);
				//}
				
				for each(var act:Object in acAnalytic){
					act.pect = Util.doCalcPercentage(act.cnt, act.ttl);
					trace(act.area + " = " + act.pect);
				}
				
			}
		
			return acAnalytic;
			
		}
		
		
		public function doAnalyticOverallByTrend():ArrayCollection{
			
			var acAnalytic:ArrayCollection = new ArrayCollection();
			var fn:String = "";
			var file:File = null;
			var now:Date = null;
			var raw:String = "";
			
			for(var n:Number = 11; n>=0; n--){ //for last 12 month
				now = new Date(); //default current based, projected last 12 month results
				now.month -= n;
				

				fn = "report_"+Constants.getHospitalId()+"_env_"+String(now.fullYear)+String(now.month+1)+".shard"; //data file / result file
				
				
				file = File.applicationStorageDirectory.resolvePath(fn);
				if(file.exists && file.size!=0){
					var stream:FileStream = new FileStream();
					stream.open(file, FileMode.READ);
					raw = stream.readUTFBytes(stream.bytesAvailable).toString(); //legnth 16 only
					stream.close();
					
					var jsonData:Object = JSON.parse(AESCrypto.decrypt(raw, Constants.getLicenseKey().substring(0,16)));
					
					var acResults:ArrayCollection = new ArrayCollection(jsonData["lstEnvResults"]);
			
					//var result:Object = doComplianceOverall(acResults);
					var objOverall:Object  = doComplianceOverall(acResults);
					
					objOverall.ym = Util.getShortMonthName(String(now.month+1)) + ", " + String(now.fullYear);
					
					
					acAnalytic.addItem(objOverall);
				} else {
					var objOverall:Object = new Object();
					objOverall.cnt = 0;
					objOverall.ttl = 0
					//not record/data
					objOverall.ym = Util.getShortMonthName(String(now.month+1)) + ", " + String(now.fullYear);
					acAnalytic.addItem(objOverall);
				}

				for each(var act:Object in acAnalytic){
					act.pect = Util.doCalcPercentage(act.cnt, act.ttl);
				}
				
			}
		
			return acAnalytic;
		}
		
		
		
		//by deficiency note
		public function doAnalyticComplianceByDeficiencyNote(yyyyMM:String, domain:String=null, filterKey:String=null):ArrayCollection{
			
			var acAnalytic:ArrayCollection = new ArrayCollection();
			
			var fn:String = "";
			var file:File = null;
			var now:Date = null;
			var raw:String = "";
			
			fn = "report_"+Constants.getHospitalId()+"_env_"+yyyyMM+".shard"; //data file / result file
			
			file = File.applicationStorageDirectory.resolvePath(fn);
			if(file.exists){
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				raw = stream.readUTFBytes(stream.bytesAvailable).toString(); //legnth 16 only
				stream.close();
				
				var jsonData:Object = JSON.parse(AESCrypto.decrypt(raw, Constants.getLicenseKey().substring(0,16)));
				
				var acResults:ArrayCollection = new ArrayCollection(jsonData["lstEnvResults"]);
				var acData:Object = null;
				var hm:HashMap = new HashMap();
				
				var noteKey:String = "";
				
				var refIds:Array = new Array();
				if(domain!=null){
					var acForm:ArrayCollection = new ArrayCollection(jsonData["lstEnvResultsForm"]);
					if(domain==Constants.DOMAIN_ENV_AREA){
						refIds = doGetRefIdByAreaId(filterKey, acForm);
					} else if(domain==Constants.DOMAIN_ENV_WARDFACILITY){
						refIds = doGetRefIdByWardFacilityId(filterKey, acForm); 
					}
				}
				
				
				for each(var result:Object in acResults){
					
					if(domain!=null){
						if(domain==Constants.DOMAIN_ENV_AREA || domain==Constants.DOMAIN_ENV_WARDFACILITY){
							if(refIds.indexOf(result.rid)==-1){
								continue;
							}
						}
					}
					
					noteKey = "";
					//get note
					//trace("result.note " + result.note + ", result.nid " + result.nid);
					if(result.nid!="0" || result.nid!=""){
						noteKey = EnvDataDictionary.getDeficiencyNoteById(result.nid);
						trace("nid get Note: " + noteKey);
						if(noteKey=="-1"){
							noteKey = ""; //reset back to "" if not found
						}
					} else {
						if(result.note!=""){
							noteKey = result.note;
							trace("user enter note: " + result.note);
						}
					}
					
					if(noteKey==""){continue;} //skip
					
					if(!hm.hasKey(noteKey)){
						acData = new Object();
						acData.note = noteKey;
						acData.ttl = 1;
						acData.cnt = 0;
						if(result.result==1){
							acData.cnt = 1;
						}
						
						acAnalytic.addItem(acData);
						hm.set(noteKey, acData);
					} else {
						
						acData = hm.get(noteKey);
						acData.ttl++;
						
						if(result.result==1){
							acData.cnt++;
						}
						
						
					}
				}
	
			}
				
			
			
			for each(var act:Object in acAnalytic){
				act.pect = Util.doCalcPercentage(act.cnt, act.ttl);
				trace("note: " + act.note + ", pect: " + act.pect);
			}
			
			return acAnalytic;
		}
		//end by deficiency note
		
		
		//start by method
		
		public function doAnalyticComplianceByMethod(yyyyMM:String, domain:String=null, filterKey:String=null):ArrayCollection{
			
			
			
			var acAnalytic:ArrayCollection = new ArrayCollection();
			
			var fn:String = "";
			var file:File = null;
			var now:Date = null;
			var raw:String = "";
			
			fn = "report_"+Constants.getHospitalId()+"_env_"+yyyyMM+".shard"; //data file / result file
			
			file = File.applicationStorageDirectory.resolvePath(fn);
			if(file.exists){
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				raw = stream.readUTFBytes(stream.bytesAvailable).toString(); //legnth 16 only
				stream.close();
				
				var jsonData:Object = JSON.parse(AESCrypto.decrypt(raw, Constants.getLicenseKey().substring(0,16)));
				
				//get acForm - filter its ref_id 
					
					//decrypt: {"lstEnvResultsForm":[{"id":11,"form_id":6,"dept_id":711,"status":0,"uid":235,"hid":111,"
					//startdatetime":"Dec 22, 2015","enddatetime":"Dec 22, 2015","createddate":"Dec 22, 2015"}],
					//"lstEnvResults":[{"id":28,"rid":11,"catid":7,"itemid":8,"method":1,"result":0,"note":"user enter note","nid":0,
					//"temp_id":"","prod_id":"","hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"},
					//{"id":29,"rid":11,"catid":8,"itemid":9,"method":2,"result":0,"note":"","nid":5,"temp_id":"","prod_id":"",
					//"hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"},
					//{"id":30,"rid":11,"catid":9,"itemid":10,"method":3,"result":2,"note":"for method 
					
				//end acForm - filter its ref_id
				var refIds:Array = new Array();
				if(domain!=null){
					var acForm:ArrayCollection = new ArrayCollection(jsonData["lstEnvResultsForm"]);
					if(domain==Constants.DOMAIN_ENV_AREA){
						refIds = doGetRefIdByAreaId(filterKey, acForm);
					} else if(domain==Constants.DOMAIN_ENV_WARDFACILITY){
						refIds = doGetRefIdByWardFacilityId(filterKey, acForm); 
					}
				}
				
				
				var acResults:ArrayCollection = new ArrayCollection(jsonData["lstEnvResults"]);
				var acData:Object = null;
				var hm:HashMap = new HashMap();
				
				for each(var result:Object in acResults){
					
					if(domain!=null){
						if(domain==Constants.DOMAIN_ENV_AREA || domain==Constants.DOMAIN_ENV_WARDFACILITY){
							if(refIds.indexOf(result.rid)==-1){
								continue;
							}
						}
					}
					
					if(!hm.hasKey(result.method)){
						
						if(domain==Constants.DOMAIN_ENV_NOTE){
							if(result.note == filterKey){
							
								acData = new Object();
								acData.methodId = result.method;
								acData.methodName = EnvDataDictionary.getMethodById(result.method);
								acData.ttl = 1;
								acData.cnt = 0;
								if(result.result==1){
									acData.cnt = 1;
								}
								
								acAnalytic.addItem(acData);
								hm.set(result.method, acData);
								
							}
						} else {
						
							acData = new Object();
							acData.methodId = result.method;
							acData.methodName = EnvDataDictionary.getMethodById(result.method);
							acData.ttl = 1;
							acData.cnt = 0;
							if(result.result==1){
								acData.cnt = 1;
							}
							
							acAnalytic.addItem(acData);
							hm.set(result.method, acData);
							
						}
						
					} else {
						
						if(domain==Constants.DOMAIN_ENV_NOTE){
							
							if(result.note == filterKey){
								acData = hm.get(result.method);
								acData.ttl++;
								
								if(result.result==1){
									acData.cnt++;
								}
							}
							
						} else {
							
							acData = hm.get(result.method);
							acData.ttl++;
							
							if(result.result==1){
								acData.cnt++;
							}
							
						}
					}
				}
				
			}
			
			
			
			for each(var act:Object in acAnalytic){
				act.pect = Util.doCalcPercentage(act.cnt, act.ttl);
				trace("method: " + act.method + ", pect: " + act.pect);
			}
			
			return acAnalytic;
		}
		
		//end by method
		
		
		//analytics by category
		
		public function doAnalyticComplianceByCategory(yyyyMM:String, domain:String=null, filterKey:String=null):ArrayCollection{
			
			var acAnalytic:ArrayCollection = new ArrayCollection();
			
			var fn:String = "";
			var file:File = null;
			var now:Date = null;
			var raw:String = "";
			
			fn = "report_"+Constants.getHospitalId()+"_env_"+yyyyMM+".shard"; //data file / result file
			
			file = File.applicationStorageDirectory.resolvePath(fn);
			if(file.exists){
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				raw = stream.readUTFBytes(stream.bytesAvailable).toString(); //legnth 16 only
				stream.close();
				
				var jsonData:Object = JSON.parse(AESCrypto.decrypt(raw, Constants.getLicenseKey().substring(0,16)));
				
				var acResults:ArrayCollection = new ArrayCollection(jsonData["lstEnvResults"]);
				var acData:Object = null;
				var hm:HashMap = new HashMap();
				
				var refIds:Array = new Array();
				if(domain!=null){
					var acForm:ArrayCollection = new ArrayCollection(jsonData["lstEnvResultsForm"]);
					if(domain==Constants.DOMAIN_ENV_AREA){
						refIds = doGetRefIdByAreaId(filterKey, acForm);
					} else if(domain==Constants.DOMAIN_ENV_WARDFACILITY){
						refIds = doGetRefIdByWardFacilityId(filterKey, acForm); 
					}
				}
				
				
				for each(var result:Object in acResults){
					
					if(domain!=null){
						if(domain==Constants.DOMAIN_ENV_AREA || domain==Constants.DOMAIN_ENV_WARDFACILITY){
							if(refIds.indexOf(result.rid)==-1){
								continue;
							}
						}
					}
					
					if(!hm.hasKey(result.catid)){
						acData = new Object();
						acData.catid = result.catid;
						acData.category = EnvDataDictionary.getCategoryById(result.catid);
						acData.ttl = 1;
						acData.cnt = 0;
						if(result.result==1){
							acData.cnt = 1;
						}
						
						acAnalytic.addItem(acData);
						hm.set(result.catid, acData);
						
					} else {
						
						acData = hm.get(result.catid);
						acData.ttl++;
						
						if(result.result==1){
							acData.cnt++;
						}
					}
				}
			}
			
			
			for each(var act:Object in acAnalytic){
				act.pect = Util.doCalcPercentage(act.cnt, act.ttl);
				trace("method: " + act.category + ", pect: " + act.pect);
			}
			
			return acAnalytic;
		}
		//end by category
		
		
		//analytics by item
		public function doAnalyticComplianceByItem(yyyyMM:String, domain:String=null, filterKey:String=null):ArrayCollection{
			
			var acAnalytic:ArrayCollection = new ArrayCollection();
			
			var fn:String = "";
			var file:File = null;
			var now:Date = null;
			var raw:String = "";
			
			fn = "report_"+Constants.getHospitalId()+"_env_"+yyyyMM+".shard"; //data file / result file
			
			file = File.applicationStorageDirectory.resolvePath(fn);
			if(file.exists){
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				raw = stream.readUTFBytes(stream.bytesAvailable).toString(); //legnth 16 only
				stream.close();
				
				var jsonData:Object = JSON.parse(AESCrypto.decrypt(raw, Constants.getLicenseKey().substring(0,16)));
				
				//get acForm - filter its ref_id 
				
				//decrypt: {"lstEnvResultsForm":[{"id":11,"form_id":6,"dept_id":711,"status":0,"uid":235,"hid":111,"
				//startdatetime":"Dec 22, 2015","enddatetime":"Dec 22, 2015","createddate":"Dec 22, 2015"}],
				//"lstEnvResults":[{"id":28,"rid":11,"catid":7,"itemid":8,"method":1,"result":0,"note":"user enter note","nid":0,
				//"temp_id":"","prod_id":"","hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"},
				//{"id":29,"rid":11,"catid":8,"itemid":9,"method":2,"result":0,"note":"","nid":5,"temp_id":"","prod_id":"",
				//"hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"},
				//{"id":30,"rid":11,"catid":9,"itemid":10,"method":3,"result":2,"note":"for method 
				
				//end acForm - filter its ref_id
				var refIds:Array = new Array();
				if(domain!=null){
					var acForm:ArrayCollection = new ArrayCollection(jsonData["lstEnvResultsForm"]);
					if(domain==Constants.DOMAIN_ENV_AREA){
						refIds = doGetRefIdByAreaId(filterKey, acForm);
					} else if(domain==Constants.DOMAIN_ENV_WARDFACILITY){
						refIds = doGetRefIdByWardFacilityId(filterKey, acForm);
					}
				}
				
				
				var acResults:ArrayCollection = new ArrayCollection(jsonData["lstEnvResults"]);
				var acData:Object = null;
				var hm:HashMap = new HashMap();
				
				for each(var result:Object in acResults){
					
					if(domain!=null){
						if(domain==Constants.DOMAIN_ENV_AREA || domain==Constants.DOMAIN_ENV_WARDFACILITY){
							if(refIds.indexOf(result.rid)==-1){
								continue;
							}
						}
					}
					
					if(!hm.hasKey(result.itemid)){
						acData = new Object();
						acData.itemId = result.itemid;
						acData.item = EnvDataDictionary.getItemById(result.itemid);
						acData.ttl = 1;
						acData.cnt = 0;
						if(result.result==1){
							acData.cnt = 1;
						}
						
						acAnalytic.addItem(acData);
						hm.set(result.method, acData);
						
					} else {
						
						acData = hm.get(result.itemid);
						acData.ttl++;
						
						if(result.result==1){
							acData.cnt++;
						}
						
					}
				}
				
			}
			
			
			
			for each(var act:Object in acAnalytic){
				act.pect = Util.doCalcPercentage(act.cnt, act.ttl);
				trace("method: " + act.item + ", pect: " + act.pect);
			}
			
			return acAnalytic;
			
		}
		//end by item
		
		
		
		public function doAnalyticEnvDashboard(yyyyMM:String):void{
		
			initConfig();
			
			var fn:String = "report_"+Constants.getHospitalId()+"_env_"+yyyyMM+".shard"; //data file / result file
			//var fn:String = "config_111_env.data"; //env config file value
			
			var file:File = null;
			file = File.applicationStorageDirectory.resolvePath(fn);
			if(file.exists){
				var stream:FileStream = new FileStream();
				stream.open(file, FileMode.READ);
				raw = stream.readUTFBytes(stream.bytesAvailable).toString(); //legnth 16 only
				stream.close();
				
				var jsonData:Object = JSON.parse(AESCrypto.decrypt(raw, Constants.getLicenseKey().substring(0,16)));
				
				var acForm:ArrayCollection = new ArrayCollection(jsonData["lstEnvResultsForm"]);
				var acResults:ArrayCollection = new ArrayCollection(jsonData["lstEnvResults"]);
				
				var acCompArea:ArrayCollection = new ArrayCollection();
				var hm:HashMap = new HashMap();
				
				var acCompAreaData:Object = null;
				
				var acAnalytic:ArrayCollection = new ArrayCollection();
				
				for each(var area:Object in acForm){
					
					if(!hm.hasKey(area.form_id)){
						acCompAreaData = new Object();
						acCompAreaData.areaId = area.form_id;
						acCompAreaData.area = EnvDataDictionary.getAreaById(area.form_id);
						
						//calculate the env results for the counts...
						var result:Object = doCompliacenByArea(area.id, acResults);
						acCompAreaData.cnt = result.cnt;
						acCompAreaData.ttl = result.ttl;
						
						hm.set(area.form_id, acCompAreaData);
						acAnalytic.addItem(acCompAreaData);
						//TODO: calculation here...
						
					} else {
						
						acCompAreaData = hm.get(area.form_id);
						//calculate the env results for the counts...
						var result:Object = doCompliacenByArea(area.id, acResults);
						acCompAreaData.cnt = result.cnt;
						acCompAreaData.ttl = result.ttl;
						
					}
				}
				
				trace("loop thru acAnalytics: " + String(acAnalytic.length));
				var objPrint:Object = null;
				for(var x:Number = 0; x < acAnalytic.length; x++){
					objPrint = acAnalytic.getItemAt(x);
					trace("obj: " + objPrint);
					trace("are: " + objPrint.areaId + ", " + objPrint.area + ", " + objPrint.cnt + ", " + objPrint.ttl);
				}
				
				//finally acAnalytics dataprovide into the charting graph to plot in data binding...
				
				//for pect calculation
				/*for each(var dept:Object in acAnalytic){
					
					//trace(dept.cat + " = " + dept.cnt + " / " + overAllCnt);
					
					//dept.pect = percentageFormat((dept.cnt/overAllCnt)*100);
					dept.pect = percentageFormat((dept.cnt/dept.opp)*100);
					
				}*/
				
				//form_id = area
				
				//compliance by area
				
				//var area:Object
				//.area = "Area"
				//.cnt = ?
				//.pect = ?
			}

				//decrypt: {"lstEnvResultsForm":[{"id":11,"form_id":6,"dept_id":711,"status":0,"uid":235,"hid":111,"
			//startdatetime":"Dec 22, 2015","enddatetime":"Dec 22, 2015","createddate":"Dec 22, 2015"}],
				//"lstEnvResults":[{"id":28,"rid":11,"catid":7,"itemid":8,"method":1,"result":0,"note":"user enter note","nid":0,
				//"temp_id":"","prod_id":"","hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"},
				//{"id":29,"rid":11,"catid":8,"itemid":9,"method":2,"result":0,"note":"","nid":5,"temp_id":"","prod_id":"",
			//"hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"},
			//{"id":30,"rid":11,"catid":9,"itemid":10,"method":3,"result":2,"note":"for method 3 and 4","nid":0,"temp_id":"ABC123","prod_id":"WP543213930","hid":111,"createddate":"Dec 22, 2015","enddatetime":"Dec 22, 2015"}]}
			
			//method 1, result 0
			//method 2, result 0
			//method 3, result 2
			
		}

		
		private function doComplianceOverall(acResults:ArrayCollection):Object{
			var obj:Object = new Object();
			obj.ttl=0; //by total
			obj.cnt=0; //by compliance
			
			for each(var result:Object in acResults){
				obj.ttl++;
				if(result.result==1){ //1 is compliance
					obj.cnt++;
				}
			}
			return obj;	
		}
		
		
		private function doComplianceByWardFacility(rid:String, acResults:ArrayCollection, domain:String=null, filterKey:String=null):Object{
			var obj:Object = new Object();
			obj.ttl=0;
			obj.cnt=0;
			
			if(domain!=null){
			
				if(domain==Constants.DOMAIN_ENV_METHOD){
					for each(var result:Object in acResults){
						//if(rids.indexOf(result.rid)!=-1){ //rid is area/form_id
						//found!
						if(result.rid==rid && result.method==filterKey){ //rid is area/form_id
							obj.ttl++;
							if(result.result==1){ //1 is compliance
								obj.cnt++;
							}
						}
					}
				}
				
			} else {
			
				for each(var result:Object in acResults){
					//if(rids.indexOf(result.rid)!=-1){ //rid is area/form_id
						//found!
					if(result.rid==rid){ //rid is area/form_id
						obj.ttl++;
						if(result.result==1){ //1 is compliance
							obj.cnt++;
						}
					}
				}
			}
			return obj;
		}
		
		private function doCompliacenByArea(rid:String, acResults:ArrayCollection, domain:String=null, filterKey:String=null):Object{
			trace("further filter by Area: " + domain + ", " + filterKey);
			//.cnt
			//.ttl
			//.pect
			var obj:Object = new Object();
			obj.ttl=0; //by total
			obj.cnt=0; //by compliance
		
			if(domain!=null){
				
				if(domain==Constants.DOMAIN_ENV_CATEGORY){ //add 1 more filter criteria
					for each(var result:Object in acResults){
						if(result.rid==rid && result.catid==filterKey){ //rid is area/form_id
							obj.ttl++;
							if(result.result==1){ //1 is compliance
								obj.cnt++;
							}
						}
					}
				}
				
			} else {
			
				for each(var result:Object in acResults){
					if(result.rid==rid){ //rid is area/form_id
						obj.ttl++;
						if(result.result==1){ //1 is compliance
							obj.cnt++;
						}
					}
				}
			}
			return obj;
		}
		
		//catid":7,"itemid":8,"method"
		
		private function doComplianceByCategory(catId:String, acResults:ArrayCollection):Object{
			var obj:Object = new Object();
			obj.ttl=0; //by total
			obj.cnt=0; //by compliance
			
			for each(var result:Object in acResults){
				if(result.catid==catId){ //category id
					obj.ttl++;
					if(result.result==1){ //1 is compliance
						obj.cnt++;
					}
				}
			}
			return obj;
		}
		
		private function doComplianceByItem(itemId:String, acResults:ArrayCollection):Object{
			var obj:Object = new Object();
			obj.ttl=0; //by total
			obj.cnt=0; //by compliance
			
			for each(var result:Object in acResults){
				if(result.itemid==itemId){ //itemid
					obj.ttl++;
					if(result.result==1){ //1 is compliance
						obj.cnt++;
					}
				}
			}
			return obj;
		}
		
		private function doComplianceByMethod(methodId:String, acResults:ArrayCollection):Object{
			var obj:Object = new Object();
			obj.ttl=0; //by total
			obj.cnt=0; //by compliance
			
			for each(var result:Object in acResults){
				if(result.method==methodId){ //rid is area/form_id
					obj.ttl++;
					if(result.result==1){ //1 is compliance
						obj.cnt++;
					}
				}
			}
			return obj;
		}
		
		//end in-memory calculation
		
		
		private function doGetRefIdByAreaId(areaId:String, acForm:ArrayCollection){
				//"lstEnvResultsForm":[{"id":11,"form_id":6,
			var refIds:Array = new Array();
			for each(var form:Object in acForm){
				if(form.form_id==areaId){
					if(refIds.indexOf(form.id)==-1){
						refIds.push(form.id);
					}
				}
			}
			return refIds;
		}
		
		
		private function doGetRefIdByWardFacilityId(wardFacilityId:String, acForm:ArrayCollection){
			//"lstEnvResultsForm":[{"id":11,"form_id":6,
			var refIds:Array = new Array();
			for each(var form:Object in acForm){
				if(form.dept_id==wardFacilityId){
					if(refIds.indexOf(form.id)==-1){
						refIds.push(form.id);
					}
				}
			}
			return refIds;
		}
		
	}
}