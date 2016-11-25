package com.semmel
{
	import flash.display.*;
	
	public class Constants extends Sprite
	{
		
		public static var url_check:String = "http://www.google.com"; //"http://192.168.220.1:8082";
		
		[Bindable]
		public static var appVersion:String;
		
		public static var progressData:String;
		//FOR DEV LOCAL
		//public static var url_domain:String = "http://localhost:8082/SEMMEL/"; //<= using for reporting BIRT engine
		//public static var url_mapi:String = "http://localhost:8082/SEMMEL/mapi"; // <== for hand hygiene module api
		//public static var url_update:String = "http://localhost:8082/SEMMEL/appupdater.xml";
		//public static var url_envapi:String = "http://localhost:8082/SEMMEL/envapi"; // <== for env module api
		
		
		//FOR PROD (Azure Server)
		public static var url_domain:String = "http://semmel.raydarhealth.com/"; //note: for reporting BIRT
		public static var url_mapi:String = "http://semmel.raydarhealth.com/mapi";
		public static var url_update:String = "http://semmel.raydarhealth.com/appupdater.xml";
		public static var url_envapi:String = "http://semmel.raydarhealth.com/envapi";
		
		public static var licenseKey:String = "";
		public static var hospId:String = "";
		public static var hospName:String = "";
		
		public static var SCREEN_HOME = "Home"; //module screen
		
		public static var MODULE_HANDHYGIENE:String = "HandHygiene";
		public static var MODULE_ENVIRONMENT:String = "Environment";
		
		public static var SCREEN_ENV_DASHBOARD = "Dashboard Summary";
		public static var SCREEN_ENV_AREA = "Compliance By Area";
		public static var SCREEN_ENV_WARDFACILITY = "Compliance By Ward/Facility";
		public static var SCREEN_ENV_NOTE = "Compliance By Deficiency Note";
		public static var SCREEN_ENV_METHOD = "Compliance By Observation Method";
		public static var SCREEN_ENV_CATEGORY = "Compliance By Category";
		public static var SCREEN_ENV_AUDIT = "Audit By Area & Ward/Facility";
		
		
		public static var FILTER_MENU_ENV_AREA = "By Area";
		public static var FILTER_MENU_ENV_WARDFACILITY = "By Ward/Facility";
		public static var FILTER_MENU_ENV_METHOD = "By Method";
		public static var FILTER_MENU_ENV_CATEGORY = "By Category";
		public static var FILTER_MENU_ENV_ITEM = "By Item";
		public static var FILTER_MENU_ENV_NOTE = "By Deficiency Note";
		
		//for env domain
		public static var DOMAIN_ENV_AREA = "area";
		public static var DOMAIN_ENV_WARDFACILITY = "wardFacility";
		public static var DOMAIN_ENV_METHOD = "method";
		public static var DOMAIN_ENV_CATEGORY = "category";
		public static var DOMAIN_ENV_ITEM = "item";
		public static var DOMAIN_ENV_NOTE = "deficiencyNote";
		//end for env domain
		
		//mobule screen
		/*acReportEnv.addItem("Home");
		acReportEnv.addItem("Dashboard Summary");
		acReportEnv.addItem("Compliance By Area");
		acReportEnv.addItem("Compliance By Ward/Facility");
		acReportEnv.addItem("Compliance By Deficiency Note");
		acReportEnv.addItem("Compliance By Area");
		acReportEnv.addItem("Compliance By Observation Method");
		acReportEnv.addItem("Compliance By Category");
		acReportEnv.addItem("Audit By Area & Ward/Facility");*/
		
		
		public function Constants()
		{
		}
		
		
		public static function setLicenseKey(key:String):void{
			licenseKey = key;
		}
		
		public static function getLicenseKey():String{
			return licenseKey;
		}
		
		public static function setHospitalId(hid:String):void{
			hospId = hid;
		}
		public static function getHospitalId():String{
			return hospId;
		}
		
		public static function setHospitalName(hname:String):void{
			hospName = hname;
		}
		public static function getHospitalName():String{
			return hospName;
		}
		
		
	}
}