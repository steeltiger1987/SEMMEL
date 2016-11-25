package com.report.env
{
	import flash.display.*;
	
	import mx.collections.ArrayCollection;
	
	public class EnvDataDictionary extends Sprite
	{
	
		public static var m_acCategory:ArrayCollection = new ArrayCollection();
		public static var m_acItem:ArrayCollection = new ArrayCollection();
		public static var m_acDeficiencyNote:ArrayCollection = new ArrayCollection();
		public static var m_acArea:ArrayCollection = new ArrayCollection();
		public static var m_acDepartment:ArrayCollection = new ArrayCollection();
		public static var m_acMethod:ArrayCollection = new ArrayCollection();
		
		//decrypt: {"category":[{"cat_id":7,"category":"Category A"},{"cat_id":8,"category":"Category B"},{"cat_id":9,"category":"Category C"}],
		//"item":[{"item_id":8,"item":"Item A","hosp_id":111},
		//{"item_id":9,"item":"Item B","hosp_id":111},{"item_id":10,"item":"Item C","hosp_id":111},{"item_id":11,"item":"Item D","hosp_id":111},
		//{"item_id":12,"item":"Item E","hosp_id":111}],
		//"department":[{"dept_id":711,"dept_name":"ICU"},{"dept_id":712,"dept_name":"Medical Ward"}],
		//"deficiencyNote":[{"nid":5,"note":"Note A"},{"nid":6,"note":"Note B"},{"nid":7,"note":"Note C"}],
		//"formTemplate":[{"form_id":6,"title":"Area A"},{"form_id":7,"title":"Area B"}]}
		
		
		public function EnvDataDictionary()
		{
		}
		
		
		public static function setCategory(acCategory:ArrayCollection):void{
			// {"category":[{"cat_id":7,"category":"Category A"}
			
			m_acCategory = acCategory;
		}
		
		public static function getCategory():ArrayCollection{
			return m_acCategory;
		}
		
		public static function getCategoryById(cat_id:String):String{
			for each(var category:Object in m_acCategory){
				if(category.cat_id == cat_id){
					return category.category;
					//break;
				}
			}
			return "-1"; //not found
			//for each(var act:Object in acAnalytic){
			//	act.pect = percentageFormat((act.cnt/overAllCnt)*100);
				//trace(act.cat + " = " + act.pect);
			//}
		}
		
		public static function setItem(acItem:ArrayCollection):void{
			m_acItem = acItem;
		}
		
		public static function getItemById(item_id:String):String{
			//"item":[{"item_id":8,"item":"Item A","hosp_id":111},
			for each(var item:Object in m_acItem){
				if(item.item_id == item_id){
					return item.item;
					//break;
				}
			}
			return "-1";
		}
		
		public static function getItem():ArrayCollection{
			return m_acItem;
		}
		
		public static function setDeficiencyNote(acDeficiencyNote:ArrayCollection):void{
			m_acDeficiencyNote = acDeficiencyNote;
		}
		
		
		public static function getDeficiencyNoteById(nid:String):String{
			////"deficiencyNote":[{"nid":5,"note":"Note A"},
			for each(var deficiencyNote:Object in m_acDeficiencyNote){
				if(deficiencyNote.nid == nid){
					return deficiencyNote.note;
					//break;
				}
			}
			return "-1";
		}
		
		public static function getDeficiencyNote():ArrayCollection{
			return m_acDeficiencyNote;
		}
		
		
		public static function setArea(acArea:ArrayCollection):void{
			trace("set area: " + String(m_acArea.length));
			m_acArea = acArea;
		}
		
		public static function getAreaById(form_id:String):String{
			////"formTemplate":[{"form_id":6,"title":"Area A"},
			trace("getAreaById: " + form_id);
			trace("acArea len: " + String(m_acArea.length));
			for each(var area:Object in m_acArea){
				trace("area object find: " + area.form_id + ", " + area.title);
				if(area.form_id == form_id){
					return area.title;
					//break;
				}
			}
			return "-1";
		}
		
		public static function getArea():ArrayCollection{
			return m_acArea;
		}
		
		public static function setDepartment(acDepartment:ArrayCollection):void{
			m_acDepartment = acDepartment;
		}
		
		public static function getDepartmentById(dept_id:String):String{
			//"department":[{"dept_id":711,"dept_name":"ICU"},
			for each(var department:Object in m_acDepartment){
				if(department.dept_id == dept_id){
					return department.dept_name;
					//break;
				}
			}
			return "-1";
		}
		
		public static function getDepartment():ArrayCollection{
			return m_acDepartment;
		}
		
		
		//get method only
		public static function getMethod():ArrayCollection{
			m_acMethod.removeAll();
			
			var obj:Object = new Object();
			obj.mid = 0;
			obj.method = "Flouracent Gel";
			m_acMethod.addItem(obj);
			
			obj = new Object();
			obj.mid = 1;
			obj.method = "Eye Observation";
			m_acMethod.addItem(obj);
			
			obj = new Object();
			obj.mid = 2;
			obj.method = "Agar Slide";
			m_acMethod.addItem(obj);
			
			obj = new Object();
			obj.mid = 3;
			obj.method = "Stick";
			m_acMethod.addItem(obj);
			
			return m_acMethod;
		}
		
		
		public static function getMethodById(mid:String):String{
			for each(var method:Object in m_acMethod){
				if(method.mid == mid){
					return method.method;
					//break;
				}
			}
			return "-1";
		}
		
	}
}