package com.maclema.mysql.events
{
	import flash.events.Event;
	import com.maclema.mysql.ResultSet;
	
	public class MySqlEvent extends Event
	{	
		public static const RESPONSE:String = "sql_response";
		public static const RESULT:String = "sql_result";
		
		//related to RESPONSE
		public var affectedRows:int;
		public var insertID:int;
		
		
		//related to RESULT
		public var resultSet:ResultSet;
		
		
		public function MySqlEvent(type:String)
		{
			super(type);
		}
	}
}