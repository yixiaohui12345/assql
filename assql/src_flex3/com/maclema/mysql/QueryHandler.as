package com.maclema.mysql
{
	import com.maclema.logging.Logger;
	import com.maclema.mysql.events.MySqlEvent;
	import com.maclema.util.ByteFormatter;
	
	import flash.utils.ByteArray;
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
		
		public function QueryHandler(con:Connection, token:MySqlToken)
		{
			super(con);
			
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
		
				var packet:Packet = nextPacket();
				
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
							readFields = true;
							working = false;
							handleNextPacket();
						}
						else
						{
							ResultSet.initialize(rs, con.connectionCharSet);
							
							evt = new MySqlEvent(MySqlEvent.RESULT);
							evt.resultSet = rs;
							
							Logger.debug(this, "Mysql Result");
							Logger.debug(this, "  Rows:       " + rs.size());
							Logger.debug(this, "  Query Size: " + ByteFormatter.format(con.tx, ByteFormatter.KBYTES, 2));
							Logger.debug(this, "  Total TX:   " + ByteFormatter.format(con.totalTX, ByteFormatter.KBYTES, 2));
							Logger.debug(this, "  Query Time: " + (getTimer()-con.lastQueryStart) + " ms");
							
							unregister();
							token.dispatchEvent(evt);
						}
					}
					else
					{
						packet.position = 0;
						
						if ( !readHeader )
						{
							rs = new ResultSet(token);
							readHeader = true;
							
							working = false;
							handleNextPacket();
						}
						else if ( !readFields )
						{
							var field:Field = new Field(packet, con.connectionCharSet);
							ResultSet.addColumn(rs, field);
						
							working = false;
							handleNextPacket();
						}
						else
						{
							var row:Array = new Array();
							while ( packet.bytesAvailable > 0 )
							{
								var value:ByteArray = packet.readLengthCodedData();
								row.push( value );
							}
							
							ResultSet.addRow(rs, row);
						
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