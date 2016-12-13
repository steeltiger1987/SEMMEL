package com
{
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	
	import spark.components.DataGrid;
	import spark.components.gridClasses.GridColumn;
	
	public class DataGridDataExporter
	{
		public static function exportCSV(dg:DataGrid, csvSeparator:String="\t", lineSeparator:String="\n"):String
		{
			var data:String = "";
			var columns:IList = dg.columns;
			var columnCount:int = columns.length;
			var column:GridColumn;
			var header:String = "";
			var headerGenerated:Boolean = false;
			var dataProvider:Object = dg.dataProvider;
			var rowCount:int = dataProvider.length;
			var dp:Object = null;
			var cursor:IViewCursor = dataProvider.createCursor();
			var j:int = 0;
			//loop through rows
			while (!cursor.afterLast)
			{
				var obj:Object = null;
				obj = cursor.current;
				//loop through all columns for the row
				for(var k:int = 0; k < columnCount; k++)
				{
					column = dg.columns.getItemAt(k) as GridColumn;
					//Exclude column data which is invisible (hidden)
					if(!column.visible)
					{
						continue;
					}
					data += "\""+ column.itemToLabel(obj)+ "\"";
					if(k < (columnCount -1))
					{
						data += csvSeparator;
					}
					//generate header of CSV, only if it's not genereted yet
					if (!headerGenerated)
					{
						header += "\"" + column.headerText + "\"";
						if (k < columnCount - 1)
						{
							header += csvSeparator;
						}
					}
				}
				headerGenerated = true;
				if (j < (rowCount - 1))
				{
					data += lineSeparator;
				}
				j++;
				cursor.moveNext ();
			}
			//set references to null:
			dataProvider = null;
			columns = null;
			column = null;
			return (header + "\r\n" + data);
		}
	}
}