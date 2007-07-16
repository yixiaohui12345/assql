package com.maclema.mysql
{
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.net.Socket;
	import flash.events.ProgressEvent;
	import com.maclema.mysql.Buffer;
	import flash.events.Event;
	
	/**
	 * This class is the base class for any class that is used as a data
	 * handler for data that the server sends and recieves.
	 **/
	public class DataHandler extends EventDispatcher
	{
		protected var con:Connection;
		private var packets:Array;
		
		public function DataHandler(con:Connection)
		{
			super();
			
			this.con = con;
			
			packets = new Array();
		}
		
		/**
		 * Called by the Connection and adds a new/recieved packet to
		 * the array of packets that need be handled.
		 **/
		public function pushPacket(packet:Packet):void
		{
			packets.push(packet);
			newPacket();
		}
        
        //overridden by handlers
        protected function newPacket():void {}
        
        /**
        * Returns the next packet that needs to be handled
        **/
        public function nextPacket():Packet
        {
        	if ( packets != null && packets.length > 0 )
	        	return Packet(packets.shift());
	        else
	        	return null;
        }
        
        protected function unregister():void
        {
        	packets = null;
        	
        	dispatchEvent(new Event("unregister"));
        }
	}
}