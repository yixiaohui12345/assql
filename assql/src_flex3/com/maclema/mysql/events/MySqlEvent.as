package com.maclema.mysql.events
{
	import flash.events.Event;
	import com.maclema.mysql.ResultSet;
	
	/**
	 * MySql Events are dispatched on successful sql queries or commands to the database. If the command sent results
	 * is a data set, a MySqlEvent.RESULT event is dispatched. In the case of a data manipulation command, a
	 * MySqlEvent.RESPONSE event is dispatched.
	 **/
	public class MySqlEvent extends Event
	{	
		public static const RESPONSE:String = "response";
		public static const RESULT:String = "result";
		
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