package com.maclema.mysql
{
	import com.maclema.logging.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
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
        protected function newPacket():void {
        	Logger.fatal(this, "NEW PACKET WAS NOT OVERRIDDEN");
        	throw new Error("newPacket() WAS NOT OVERRIDDEN");
        }
        
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