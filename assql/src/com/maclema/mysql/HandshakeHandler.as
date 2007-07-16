package com.maclema.mysql
{
	import flash.events.Event;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	/**
	 * This class handles completing the handshake between this driver
	 * and the mysql server
	 **/
	public class HandshakeHandler extends DataHandler
	{
		private var username:String;
		private var password:String;
		private var database:String;
		
		private var connectWithDb:Boolean = false;
		
		private var inPacketCount:int = 0;
		
		public function HandshakeHandler(con:Connection, username:String, password:String, database:String)
		{
			super(con);
			
			this.username = username;
			this.password = password;
			this.database = database;
		}
		
		override protected function newPacket():void
		{
			inPacketCount++;
			
			if ( inPacketCount == 1 )
			{
				con.server = new ServerInformation( nextPacket() );
				doHandshake();
			}
			else if ( inPacketCount == 2 )
			{
				var packet:Packet = nextPacket();
				var field_count:int = packet.readByte() & 0xFF;
				
				if ( field_count == 0x00 )
				{
					//ok packet
					
					if ( connectWithDb )
					{
						//send command
						con.changeDatabaseTo(database);
					}
					else
					{
						//woop! were authenticated
						unregister();
						con.dispatchEvent(new Event(Event.CONNECT));
					}
				}
				else if ( field_count == 0xFF || field_count == -1 )
				{
					unregister();
					new ErrorHandler( packet, con );
				}
			}
			else if ( connectWithDb && inPacketCount == 3 )
			{
				var packet:Packet = nextPacket();
				var field_count:int = packet.readByte() & 0xFF;
				
				if ( field_count == 0x00 )
				{
					//woop! were authenticated
					unregister();
					con.dispatchEvent(new Event(Event.CONNECT));
				}
				else if ( field_count == 0xFF || field_count == -1 )
				{
					unregister();
					new ErrorHandler( packet, con );
				}
			}
		}
		
		private function doHandshake():void
		{
			if ( con.server.meetsVersion( 4, 1, 22 ) )
			{
				if ( database != null )
				{
					con.clientParam |= Mysql.CLIENT_CONNECT_WITH_DB;
					connectWithDb = true;
				}
				
				if ( con.server.isCapableOf( Mysql.CLIENT_LONG_FLAG ) )
				{
					con.clientParam |= Mysql.CLIENT_LONG_FLAG;
					con.hasLongColumnInfo = true;
				}
				
				//return found rows
                con.clientParam |= Mysql.CLIENT_FOUND_ROWS;
    
                //use the new password encryption
                con.clientParam |= Mysql.CLIENT_LONG_PASSWORD;
                
                //use the 4.1.1 protocol
                con.clientParam |= Mysql.CLIENT_PROTOCOL_41;
                
                //use transactions
                con.clientParam |= Mysql.CLIENT_TRANSACTIONS;
                
                //return multiple result sets
                con.clientParam |= Mysql.CLIENT_MULTI_RESULTS;
                
                //For some reason this check always fails and you get a NotImplementedError.. need to fix before
                //I can support the old password hashing.
                //do secure authentication?
                //if ( server.isCapableOf( Mysql.CLIENT_SECURE_CONNECTION ) )
                //{
                    con.clientParam |= Mysql.CLIENT_SECURE_CONNECTION;
                    doSecureAuthentication();
                //}    
                //else
                //{
                //    throw new NotImplementedError("Currently only connecting with the new 'long password' is supported");
                //}
			}
			else
			{
				throw new Error("Unsupported Server Version");
			}
		}
		
		/* completes the authentication */
		private function doSecureAuthentication():void
		{
			//the packet to send
			var packet:Packet = new Packet();
			
			//write the client parameters
			packet.writeInt( con.clientParam );
			
			// write the maximum packet sixe
			packet.writeInt( Packet.maxThreeBytes );
			
			//language
			packet.writeByte( 8 ); //charset
			
			//the 23-byte null filler
			packet.writeNullBytes(23);
			
			//the username
			packet.writeString(username);
			
			if ( password != null )
			{
				var scrambledPassword:ByteArray = Util.scramble411( password, con.server.seed );
				packet.writeBytes(scrambledPassword);    
			}
			else
			{
				//empty password
				packet.writeByte(0x00);
			}
			
			//another null filler
			packet.writeByte(0x00); //filler
			
			//are we connecting using a database name?
			if ( connectWithDb && database != null )
			{
			    packet.writeString(database);
			}
			
			//send the packet. For some reason the handshake packet secuence needs to 
			//start at 1 rather then 0 like the rest of the packets, so we can specify
			//that here.
			packet.send(con.getSocket(), 1);
		}
	}
}