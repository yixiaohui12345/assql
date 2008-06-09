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
		
		/**
		 * The number of affected rows for a RESPONSE event.
		 **/
		public var affectedRows:int;
		
		/**
		 * The insert id for a RESPONSE event.
		 **/
		public var insertID:int;
		
		/**
		 * The ResultSet for a RESULT event
		 **/
		public var resultSet:ResultSet;
		
		/**
		 * Constructs a new MySqlEvent object.
		 **/
		public function MySqlEvent(type:String)
		{
			super(type);
		}
	}
}