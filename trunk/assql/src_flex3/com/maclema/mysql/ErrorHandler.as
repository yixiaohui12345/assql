package com.maclema.mysql
{
	import flash.events.IEventDispatcher;
	import com.maclema.mysql.events.MySqlErrorEvent;
	
	internal class ErrorHandler
	{
		public function ErrorHandler( packet:Packet, dispatchOn:IEventDispatcher )
		{
			var id:int = packet.readShort();
            packet.readByte(); //# marker
            var sqlstate:String = packet.readUTFBytes(5);    
            var msg:String = packet.readUTFBytes(packet.bytesAvailable);
            
            dispatchOn.dispatchEvent(new MySqlErrorEvent(msg, id));
		}
	}
}