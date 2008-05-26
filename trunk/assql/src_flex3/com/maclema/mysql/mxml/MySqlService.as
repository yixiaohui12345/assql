package com.maclema.mysql.mxml
{
	import com.maclema.mysql.MySqlService;
	import com.maclema.mysql.events.MySqlErrorEvent;
	import com.maclema.mysql.events.MySqlEvent;
	
	import flash.events.Event;
	
	import mx.core.IMXMLObject;
	import mx.managers.CursorManager;
	import mx.rpc.mxml.Concurrency;
	import mx.rpc.mxml.IMXMLSupport;
	
	public class MySqlService extends com.maclema.mysql.MySqlService implements IMXMLSupport, IMXMLObject
	{
		private var _showBusyCursor:Boolean = false;
		
		/**
		 * Should this service auto connect when ready? Default: false;
		 **/
		public var autoConnect:Boolean = false;
		
		public function MySqlService()
		{
			addEventListener(MySqlErrorEvent.SQL_ERROR, removeBusyCursor);
			addEventListener(MySqlEvent.RESULT, removeBusyCursor);
			addEventListener(MySqlEvent.RESPONSE, removeBusyCursor);
			addEventListener(Event.CLOSE, removeBusyCursor);
		}
		
		public function initialized(document:Object, id:String):void {
			if ( autoConnect ) {
				connect();
			}
		}
		
		public function get concurrency():String {
			return Concurrency.LAST;
		}
		
		public function set concurrency(value:String):void {
			//do nothing
		}
		
		public function get showBusyCursor():Boolean {
			return _showBusyCursor;
		}
		
		public function set showBusyCursor(value:Boolean):void {
			_showBusyCursor = value;
		}
		
		override public function send(queryObject:*):void {
			super.send(queryObject);
			
			if ( showBusyCursor ) {
				CursorManager.setBusyCursor();
			}
		}
		
		private function removeBusyCursor(e:Event=null):void {
			CursorManager.removeBusyCursor();
		}
	}
}