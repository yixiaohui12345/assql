package com.maclema.util
{
	import com.maclema.mysql.Field;
	import com.maclema.mysql.ResultSet;
	
	import mx.controls.dataGridClasses.DataGridColumn;
	
	public class ResultsUtil
	{
		/**
		 * Takes a ResultSet and returns an array valid for being used as a 
		 * DataGrid's columns property.
		 **/
		public static function getDataGridColumns(rs:ResultSet):Array {
			var cols:Array = rs.getColumns();
			var newcols:Array = new Array();
			for ( var i:int=0; i<cols.length; i++ ) {
				var clmName:String = Field(cols[i]).getName();
				var clm:DataGridColumn = new DataGridColumn( clmName );
				clm.dataField = clmName;
				newcols.push(clm);
			}
			return newcols;
		}

	}
}