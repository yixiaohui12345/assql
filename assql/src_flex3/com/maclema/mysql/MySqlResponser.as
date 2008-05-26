package com.maclema.mysql
{
	import com.maclema.mysql.events.MySqlErrorEvent;
	import com.maclema.mysql.events.MySqlEvent;
	
	import mx.rpc.IResponder;
	
	public class MySqlResponser implements IResponder
	{
		public var responseHandler:Function;
		public var errorHandler:Function;
		
		public function MySqlResponser(responseHandler:Function, errorHandler:Function)
		{
			this.responseHandler = responseHandler;
			this.errorHandler = errorHandler;
		}
		
		public function result(data:Object):void {
			if ( responseHandler != null ) {
				responseHandler(MySqlEvent(data));
			}
		}
		
		public function fault(data:Object):void {
			if ( errorHandler != null ) {
				errorHandler(MySqlErrorEvent(data));
			}
		}
	}
}