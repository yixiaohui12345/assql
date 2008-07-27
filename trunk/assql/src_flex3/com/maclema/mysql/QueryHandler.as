package com.maclema.mysql
{
	import com.maclema.logging.Logger;
	import com.maclema.mysql.events.MySqlEvent;
	import com.maclema.util.ByteFormatter;
	
	import flash.utils.getTimer;
	
	/**
	 * Handles recieving and parsing the data sent by the MySql server
	 * in response to a query.
	 **/
	internal class QueryHandler extends DataHandler
	{
		private var token:MySqlToken;
		private var rs:ResultSet;
		
		private var readHeader:Boolean = false;
		private var readFields:Boolean = false;
		
		private var working:Boolean = false;
		
		public function QueryHandler(connInstanceID:int, token:MySqlToken)
		{
			super(connInstanceID);
			
			this.token = token;
		}
		
		override protected function newPacket():void
		{
			handleNextPacket();
		}
		
		private function handleNextPacket():void
		{
			if ( !working )
			{
				working = true;
		
				var packet:ProxiedPacket = nextPacket();
				
				if ( packet != null )
				{
					var evt:MySqlEvent;
					var field_count:int = packet.readByte() & 0xFF;
				
					if ( field_count == 0x00 )
					{
						var rows:int = packet.readLengthCodedBinary();
						var insertid:int = packet.readLengthCodedBinary();
						evt = new MySqlEvent(MySqlEvent.RESPONSE);
						evt.affectedRows = rows;
						evt.insertID = insertid;
						
						unregister();
						token.dispatchEvent(evt);
					}
					else if ( field_count == 0xFF || field_count == -1 )
					{
						unregister();
						new ErrorHandler(packet, token);	
					}
					else if ( packet.length == 5 && (field_count == 0xFE || field_count == -2) )
					{	
						packet.position = 0;
						
						//eof packet
						if ( !readFields )
						{
							Logger.info(this, "Reading Row Data...");
							readFields = true;
							working = false;
							handleNextPacket();
						}
						else
						{
							Logger.info(this, "Initializating ResultSet...");
							
							rs.initialize(Connection.getInstance(connInstanceID).connectionCharSet);
							
							evt = new MySqlEvent(MySqlEvent.RESULT);
							evt.resultSet = rs;
							
							Logger.debug(this, "Mysql Result");
							Logger.debug(this, "  Rows:       " + rs.size());
							Logger.debug(this, "  Query Size: " + ByteFormatter.format(Connection.getInstance(connInstanceID).tx, ByteFormatter.KBYTES, 2));
							Logger.debug(this, "  Total TX:   " + ByteFormatter.format(Connection.getInstance(connInstanceID).totalTX, ByteFormatter.KBYTES, 2));
							Logger.debug(this, "  Query Time: " + (getTimer()-Connection.getInstance(connInstanceID).lastQueryStart) + " ms");
							
							unregister();
							token.dispatchEvent(evt);
						}
					}
					else
					{
						packet.position = 0;
						
						if ( !readHeader )
						{
							Logger.info(this, "Reading Column Data...");
							rs = new ResultSet(token);
							readHeader = true;
							
							working = false;
							handleNextPacket();
						}
						else if ( !readFields )
						{
							var field:Field = new Field(packet, Connection.getInstance(connInstanceID).connectionCharSet);
							rs.addColumn(field);
						
							working = false;
							handleNextPacket();
						}
						else
						{
							rs.addRow(packet);
						
							working = false;
							handleNextPacket();
						}
					}
				}
				else
				{
					working = false;
				}
			}
		}
	}
}