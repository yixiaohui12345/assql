package com.maclema.mysql
{
	import com.maclema.logging.Logger;
	import com.maclema.mysql.events.MySqlErrorEvent;
	import com.maclema.mysql.events.MySqlEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.rpc.IResponder;
	
	[Event(name="sqlError", type="com.maclema.mysql.events.MySqlErrorEvent")]
    [Event(name="response", type="com.maclema.mysql.events.MySqlEvent")]
    [Event(name="result", type="com.maclema.mysql.events.MySqlEvent")]
	public class MySqlToken extends EventDispatcher
	{
		/**
		 * This is a property you can use to attach additional information to be returned in the reponders
		 **/
		public var info:Object;
		
		/**
		 * An array of IResponder handlers that will be called when the query completes.
		 **/
		public var responders:Array = new Array();
		
		/**
		 * The result returned by the query. Either a ResultSet (for query statements), and an object with
		 * two properties, affectedRows and insertID
		 **/
		public var result:Object;
		
		/**
		 * Constructs a new MySqlToken
		 **/
		public function MySqlToken()
		{
			this.addEventListener(MySqlEvent.RESPONSE, handleResponse);
            this.addEventListener(MySqlEvent.RESULT, handleResponse);
            this.addEventListener(MySqlErrorEvent.SQL_ERROR, handleError);
		}
		
		private function handleResponse(e:MySqlEvent):void {
        	if ( this.hasResponder() ) {
	        	var data:Object;
	        	if ( e.type == MySqlEvent.RESULT ) {
	        		data = e.resultSet;
	        	}
	        	else {
	        		data = {
	        			affectedRows: e.affectedRows,
	        			insertID: e.insertID
	        		}
	        	}
	        	
	        	Logger.info(this, "Dispatching Result/Response Responders");
	        	
	        	for ( var i:int=0; i<responders.length; i++ ) {
	        		var responder:IResponder = IResponder(responders[i]);
	        		responder.result(data);
	        	}
        	}
        }
        
        private function handleError(e:MySqlErrorEvent):void {
        	if ( this.hasResponder() ) {
	        	var data:Object = e.text;
	        	
	        	Logger.info(this, "Dispatching Fault Responders");
	        	
	        	for ( var i:int=0; i<responders.length; i++ ) {
	        		var responder:IResponder = IResponder(responders[i]);
	        		responder.result(data);
	        	}
        	}
        }
		
		/**
		 * Adds a responder to an array of responders
		 **/
		public function addResponder(responder:IResponder):void {
			responders.push(responder);
		}
		
		/**
		 * Determines if this token has at least one IResponder registered
		 **/
		public function hasResponder():Boolean {
			if ( responders.length > 0 ) {
				return true;
			}
			return false;
		}
	}
}