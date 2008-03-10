package com.maclema.mysql
{
	import com.maclema.mysql.events.MySqlEvent;
	
	public class CommandHandler extends DataHandler
	{
		public function CommandHandler(con:Connection)
		{
			super(con);
		}
		
		override protected function newPacket():void
		{
			handleNextPacket();
		}
		
		private function handleNextPacket():void
		{
			var packet:Packet = nextPacket();
			
			if ( packet != null )
			{
				var evt:MySqlEvent;
				var field_count:int = packet.readByte() & 0xFF;
			
				if ( field_count == 0x00 )
				{
					evt = new MySqlEvent(MySqlEvent.RESPONSE);
					con.dispatchEvent(evt);
					unregister();
				}
				else if ( field_count == 0xFF || field_count == -1 )
				{
					unregister();
					new ErrorHandler(packet, con);
				}
			}
		}
	}
}