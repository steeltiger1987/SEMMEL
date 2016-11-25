package com.report.bi
{
	import flash.filesystem.*;
	
	import mx.collections.ArrayCollection;

	
	public class SemmelReport
	{
		
		public static var AdMoment:String = 'AdMoment';
		public static var AdWard:String = "AdWard";
		public static var AdProf:String = "AdProf";
		
		public static var AdMTD:String = "AdMTD";
		
		//trend report
		public static var WardFacilityTrend = "WardFacilityTrend";
		public static var ProfTrend = "ProfTrend";
		
		//the missing report
		public static var AvgActions = "AvgAction";
		
		
		public static var OppAdWardFacility:String = "OppAdWardFacility"; //14 inherit from 2
		public static var OppAdProfession:String = "OppAdProfession"; //15 inherit from 3
		public static var OppAdMoment:String = "OppAdMoment";
		
		public static var OppProcedure:String = "OppProcedure"; // 
		public static var OppReason:String = "OppReason"; //
		
		
		//for Environmental
		public static var EnvComplianceByArea:String = "50";
		public static var EnvComplianceByWardFacility = "51";
		public static var EnvOverallCompliance = "52";
		public static var EnvOverallComplianceByTrend = "53";
		public static var EnvComplianceByNote = "54";
		public static var EnvComplianceByMethod = "55";
		public static var EnvComplianceByCategory = "56";
		public static var EnvComplianceTrendByCategory = "57";
		//end for environmental
		
		
		public static var acReportsListing:ArrayCollection = new ArrayCollection();
		
		public function SemmelReport()
		{
			
		}
		
		//For report listing naming display
		public static function getJSONReport(report:String):String{
			var json:String = "";
			if(report=="AdMoment"){
				json = '{"id":"AdMoment","title":"Adherence by Moments"}';
			} else if(report=="AdWard"){
				json = '{"id":"AdMoment","title":"Adherence by Ward/Facility"}';
			} else if(report=="AdProf"){
				json = '{"id":"AdMoment","title":"Adherence by Profession"}';
			} else if(report=="AdMTD"){
				json = '{"id":"AdMTD","title":"Adherence MTD"}';
			} else if(report=="OppAdWardFacility"){
				json = '{"id":"OppAdWardFacility","title":"Opportunity vs. Adherence by Ward/Facility"}';
			} else if(report=="OppAdProfession"){
				json = '{"id":"OppAdProfession","title":"Opportunity vs. Adherence by Professional"}';
			} else if(report=="OppAdMoment"){
				json = '{"id":"OppAdMoment","title":"Opportunity vs. Adherence by Moments"}';
			} else if(report=="WardFacilityTrend"){
				json = '{"id":"WardFacilityTrend","title":"Ward/Facility Adherence By Trend"}';
			} else if(report=="ProfTrend"){
				json = '{"id":"ProfTrend","title":"Profession Adherence By Trend"}';
			} else if(report=="AvgAction"){
				json = '{"id":"AvgAction","title":"Average Action By Moments"}';
			} else if(report=="OppProcedure"){
				json = '{"id":"OppProcedure","title":"Aseptic Procedure Summary"}';
			} else if(report=="OppReason"){
				json = '{"id":"OppReason","title":"Missed with Reason Summary"}';
			} else if(report==EnvComplianceByArea){ //FOR ENVIRONMENTAL
				json = '{"id":"EnvComplianceByArea", "title":"Compliance By Area"}';
			} else if(report==EnvComplianceByWardFacility){
				json = '{"id":"EnvComplianceByWardFacility", "title":"Compliance By Ward/Facility"}';
			} else if(report==EnvOverallCompliance){
				json = '{"id":"EnvOverallCompliance", "title":"Overall Compliance"}';
			} else if(report==EnvOverallComplianceByTrend){
				json = '{"id":"EnvOverallComplianceByTrend", "title":"Overall Compliance"}';
			} else if(report==EnvComplianceByNote){
				json = '{"id":"EnvComplianceByNote", "title":"Compliance By Deficiency Note"}';
			} else if(report==EnvComplianceByMethod){
				json = '{"id":"EnvComplianceByMethod", "title":"Compliance By Method"}';
			} else if(report==EnvComplianceByCategory){
				json = '{"id":"EnvComplianceByCategory", "title":"Compliance By Category"}';
			} else if(report==EnvComplianceTrendByCategory){
				json = '{"id":"EnvComplianceTrendByCategory", "title":"Compliance Trend By Category"}';
			}
					
			return json;
		}
		
		
		//for common getCID - get chart id component
		public static function getCID(chart:String, domain:String="", groupBy:String=""):String{
			var cid:String = "";
			//common report / fix report
			trace("get cid - domain: " + domain);
			if(domain==""){
				if(chart==SemmelReport.AdMoment){
					cid = "1";	
				} else if(chart==SemmelReport.AdWard){
					cid = "2";
				} else if(chart==SemmelReport.AdProf){
					cid = "3";
				} else if(chart==SemmelReport.AdMTD){
					cid = "4";
				} else if(chart==SemmelReport.OppAdWardFacility){
					cid = "14"; //break into 14.1, 14.2 inherit from 2
				} else if(chart==SemmelReport.OppAdProfession){
					cid = "15"; //break into 15.1, 15.2 inherit from 3
				} else if(chart==SemmelReport.OppAdMoment){
					cid = "16"; //break into 16.1, 16.2 inherit from 1
				} else if(chart==SemmelReport.WardFacilityTrend){
					cid = "17"; //with start/end + wards
				} else if(chart==SemmelReport.ProfTrend){
					cid = "18"; //with start/end, ward, profs
				} else if(chart==SemmelReport.AvgActions){
					cid = "19"; //avg action by moments
				} else if(chart==SemmelReport.OppProcedure){
					cid = "22"; //procedure summary (aseptic)
				} else if(chart==SemmelReport.OppReason){
					cid = "23"; //reason summary
				} else if(Number(chart)>=50){ //is for environment
					cid = chart; // return as it
				}
				
			} else {
				//debug: domain procedure gb: By Action
				trace("domain " + domain + " gb: " + groupBy);
				//for MOMENT domain
				if(domain=="moment" && groupBy=="By Ward/Facility"){
					cid = "5";
				} else if(domain=="moment" && groupBy=="By Professional"){
					cid = "6";
				} else if(domain=="moment" && groupBy=="By Action"){
					cid = "7";
				} else if(domain=="moment" && groupBy=="By Reason"){
					cid = "24"; //for moment - reason
				//for DEPARTMENT domain (actually is ward/facility)
				} else if(domain=="department" && groupBy=="By Professional"){
					cid = "8";
				} else if(domain=="department" && groupBy=="By Moment"){
					cid = "9";
				} else if(domain=="department" && groupBy=="By Action"){
					cid = "10";
				} else if(domain=="department" && groupBy=="By Reason"){
					cid = "25"; //for department - reason
				//for PROFESSION domain
				} else if(domain=="profession" && groupBy=="By Ward/Facility"){
					cid = "11";
				} else if(domain=="profession" && groupBy=="By Moment"){
					cid = "12";
				} else if(domain=="profession" && groupBy=="By Action"){
					cid = "13";
				} else if(domain=="profession" && groupBy=="By Reason"){
					cid = "26"; //for profession - reason
				} else if(domain=="reason" && groupBy=="By Moment"){
					cid = "27"; // for reason by moment
				} else if(domain=="reason" && groupBy=="By Ward/Facility"){
					cid = "28";
				} else if(domain=="reason" && groupBy=="By Professional"){
					cid = "29";
				} else if(domain=="procedure" && groupBy=="By Action"){
					cid = "30";
				} else if(domain=="procedure" && groupBy=="By Ward/Facility"){
					cid = "31";
				} else if(domain=="procedure" && groupBy=="By Professional"){
					cid = "32";
				}
				//27 = reason by moment
				//28 = reason by ward/facility
				//29 = reason by prof
				
				//30 = procedure by momebt
				//31 = prodc by wat/facity
				//32 = proc by prof
			}
			return cid;
		}
		//end for common getCID - get chart id component
		
		
		
		
		public static function addReport(reportTitle:String, charts:Array):void{
			
			var now:Date = new Date();
			var timestamp:String = now.valueOf().toString();
			
			var objReport:Object = new Object();
			objReport.id = timestamp;
			objReport.reportTitle = reportTitle;
			objReport.charts = charts;
			
			trace("addReport...");
			trace(timestamp);
			trace(reportTitle);
			trace(JSON.stringify(objReport));
		
			var acReports:ArrayCollection = new ArrayCollection();
			
			var file:File = File.applicationStorageDirectory.resolvePath("custom_report.dat");
			if(file.exists){
			
				try{
					var stream:FileStream = new FileStream()
					stream.open(file, FileMode.READ);
					var s:String = stream.readUTFBytes(stream.bytesAvailable).toString();
					stream.close();
					
					
					var jsonReports = JSON.parse(s);
					
					var jArray:Array = jsonReports.reports;
					
					var isForNew:Boolean = true;
					for(var iR:Number=0;iR<jArray.length;iR++){
						trace(jArray[iR].reportTitle + " vs " + reportTitle);
						if(jArray[iR].reportTitle==reportTitle){
							isForNew = false;
							jArray[iR].charts = charts;
							trace(JSON.stringify(jArray[iR]));
							break;
						}
					}
					
					
					if(isForNew){
						trace("arr len: " + jArray.length.toString());
						jArray.push(objReport);
						trace(JSON.stringify(jArray));
					}
					
					//for the insert reports...
					try {
						var file:File = File.applicationStorageDirectory.resolvePath("custom_report.dat");
						var fileStream:FileStream = new FileStream();
						fileStream.open(file, FileMode.WRITE);
						
						//create root report json with array
						var rootReport:Object = new Object();
						
						rootReport.reports = jArray;
						
						fileStream.writeUTFBytes(JSON.stringify(rootReport));
						fileStream.close();
					}catch(e:Error){
						trace("save custom report: " + e.toString());
					}
					
					
					
				} catch(e:Error){
					trace("error custom_report.dat " + e.toString());
				}
				
			} else {
			
				//for the 1st time
				try {
					var file:File = File.applicationStorageDirectory.resolvePath("custom_report.dat");
					var fileStream:FileStream = new FileStream();
					fileStream.open(file, FileMode.WRITE);
					
					//create root report json with array
					var rootReport:Object = new Object();
					var arrReport:Array = new Array();
					arrReport.push(objReport);
					rootReport.reports = arrReport;
					
					fileStream.writeUTFBytes(JSON.stringify(rootReport));
					fileStream.close();
				}catch(e:Error){
					trace("create new save custom report: " + e.toString());
				}
			
			}
			
			loadReportListing();
		}
		
		public static function removeReportsChart(ixReport:Number, arChart:Array, countryCode:String):void{
			
			
			//copy as another copy after remove CHART
			
			//var charts:Array = acReportsListing.getItemAt(ixReport).charts;
			
			//trace("charts: " + charts.length);
			
			//update the latest charts into report!
			acReportsListing.getItemAt(ixReport).charts = arChart;
			
			
			try {
				var file:File = File.applicationStorageDirectory.resolvePath("custom_report.dat");
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				
				//create root report json with array
				var rootReport:Object = new Object();
				var arrReport:Array = new Array();
				
				if(countryCode=="MY"){	
					for(var i:Number=2;i<acReportsListing.length;i++){ //always skip the MOH report and Audit Report the 1st/2nd one
						arrReport.push(acReportsListing[i]);
					}
				} else {
					for(var i:Number=0;i<acReportsListing.length;i++){
						arrReport.push(acReportsListing[i]);
					}
				}
				
				rootReport.reports = arrReport;
				
				fileStream.writeUTFBytes(JSON.stringify(rootReport));
				fileStream.close();
			}catch(e:Error){
				trace("delete chart save report: " + e.toString());
			}
			//end copy as another copy after remove CHART
			
		}
		
		public static function removeReport(ix:Number, countryCode:String):void{
			
			//copy as another copy after remove
			
			//acReportsListing.removeItemAt(ix-1);
			
			try {
				var file:File = File.applicationStorageDirectory.resolvePath("custom_report.dat");
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				
				//create root report json with array
				var rootReport:Object = new Object();
				var arrReport:Array = new Array();
				
				if(countryCode=="MY"){
					for(var i:Number=2;i<acReportsListing.length;i++){ //alwasy skip the MOH report
						arrReport.push(acReportsListing[i]);
					}
				} else {
					for(var i:Number=0;i<acReportsListing.length;i++){ //alwasy skip the MOH report
						arrReport.push(acReportsListing[i]);
					}
				}
				rootReport.reports = arrReport;
				
				fileStream.writeUTFBytes(JSON.stringify(rootReport));
				fileStream.close();
			}catch(e:Error){
				trace("delete report save report: " + e.toString());
			}
			//end copy as another copy after remove
			
		}
		
		public static function loadReportListing():void{
			
			var file:File = File.applicationStorageDirectory.resolvePath("custom_report.dat");
			if(file.exists){
				try{
					var stream:FileStream = new FileStream()
					stream.open(file, FileMode.READ);
					var s:String = stream.readUTFBytes(stream.bytesAvailable).toString();
					

					var jsonReports = JSON.parse(s);
					
					//var jArray:Array = jsonReports.reports;
					//OR for binding using AC
					
					acReportsListing = new ArrayCollection(jsonReports.reports);
					trace("Availale list: " + acReportsListing.length.toString());
					
					//acReportsListing.removeItemAt(0);
					
					
					//trace("ReportTItle: " + jsonReports.reports[0].reportTitle);
					//var mohChart:Object = new Object(); 
					//mohChart.cid = "moh_my";
					//mohChart.title = "MOH Report";
					//mohChart.label = "MOH Report";
					
					stream.close();
					
				} catch(e:Error){
					trace("error custom_report.dat " + e.toString());
				}
			}
		}
	}
}