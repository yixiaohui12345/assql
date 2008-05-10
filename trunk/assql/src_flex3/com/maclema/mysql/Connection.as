package com.maclema.mysql
{
	import com.maclema.mysql.events.MySqlErrorEvent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.getTimer;
	
	[Event(name="sqlError", type="com.maclema.mysql.events.MySqlErrorEvent")]
	[Event(name="sql_response", type="com.maclema.mysql.events.MySqlEvent")]
	[Event(name="connect", type="flash.events.Event")]
	[Event(name="close", type="flash.events.Event")]
	public class Connection extends EventDispatcher
	{
		//the actual socket
		private var sock:Socket;
		
		//connection information
		private var host:String;
		private var port:int;
		private var username:String;
		private var password:String;
		private var database:String;
		
		//the current data reader
		private var dataHandler:DataHandler;
		
		//the server information
		public var server:ServerInformation;
		
		//the client capabilities
		public var clientParam:Number = 0;
		
		private var expectingClose:Boolean = false;
		
		public var hasLongColumnInfo:Boolean = false;
		
		private var buffer:Buffer;
		
		private var _connected:Boolean = false;
		
		private var _totalTX:Number;
		private var _tx:Number;
		private var _queryStart:Number;
		
		/**
		 * Creates a new connection to a MySql server.
		 **/
		public function Connection( host:String, port:int, username:String, password:String = null, database:String = null )
		{
			super();
			
			buffer = new Buffer();
			
			//set the connection information	
			this.host = host;
			this.port = port;
			this.username = username;
			this.password = password;
			this.database = database;
			
			if ( this.database == "" )
			{
				this.database = null;
			}
			
			if ( this.password == "" )
			{
				this.password = null;
			}
			
			this.addEventListener(Event.CONNECT, onConnected);
			this.addEventListener(Event.CLOSE, onDisconnect);
			
			//create the connection to the server
			sock = new Socket();
			sock.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
            sock.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketError);
            sock.addEventListener(Event.CONNECT, onSocketConnect);
            sock.addEventListener(Event.CLOSE, onSocketClose);
            sock.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
		}
		
		private function onConnected(e:Event):void
		{
			this._connected = true;
			dispatchEvent(new Event("connectionStateChanged"));
		}
		
		private function onDisconnect(e:Event):void
		{
			this._connected = false;
			dispatchEvent(new Event("connectionStateChanged"));
		}
		
		[Bindable("connectionStateChanged")]
		public function get connected():Boolean
		{
			return _connected;
		}
		
		private function onSocketError(e:ErrorEvent):void
		{
			dispatchEvent(new MySqlErrorEvent(e.text));
		}
		
		private function onSocketConnect(e:Event):void
		{
			
		}
		
		private function onSocketClose(e:Event):void
		{
			if ( !expectingClose )
			{
				trace("Connection Terminated Unexpectedly!");
			}
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function onSocketData(e:ProgressEvent):void
		{
			_tx += sock.bytesAvailable;
			_totalTX += sock.bytesAvailable;
			
			sock.readBytes( buffer, buffer.length, sock.bytesAvailable );
			checkForPackets();		
		}
		
		private function checkForPackets():void
        {
        	buffer.position = 0;
        	
            if ( buffer.bytesAvailable >= 4 )
            {
            	//get packet information
                var len:Number = buffer.readThreeByteInt();
                var num:int = buffer.readByte();
 
                //is there a whole packet downloaded?
                if ( buffer.bytesAvailable >= len )
                {	
                    //read the packet
                    buffer.position = 0;
                    
                    var pack:Packet = new Packet(buffer);
                    
                    //remove the read packet from the inBuffer
                    var tmp:Buffer = buffer;
                    buffer = new Buffer();
                    tmp.readBytes(buffer);
                    tmp = null;
                    
                   	if ( dataHandler != null )
                   	{
                   		dataHandler.pushPacket( pack );
                   	}
                    
                    checkForPackets();
                }
        	}
        }
		
		private function setDataHandler(handler:DataHandler):void
		{
			if ( dataHandler != null )
			{
				dataHandler.removeEventListener( "unregister", unregisterDataHandler );
			}
			
			dataHandler = null;
			
			dataHandler = handler;
			dataHandler.addEventListener( "unregister", unregisterDataHandler );
		}
		
		private function unregisterDataHandler(e:Event):void
		{
			dataHandler.removeEventListener( "unregister", unregisterDataHandler );
		}
		
		/**
		 * Opens the socket connection to the server
		 **/
		public function connect():void
		{
			_tx = 0;
			_totalTX = 0;
			
			//set the dataHandler
			setDataHandler( new HandshakeHandler(this, username, password, database) );
			
			sock.connect( host, port );
		}
		
		/**
		 * Disconnects the socket from the server.
		 **/
		public function disconnect():void
		{
			expectingClose = true;
			
			if ( sock.connected )
			{
				sock.close();
				
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
		/**
         * Creates a new statement object
         **/
        public function createStatement():Statement
        {
            return new Statement(this);
        }
        
        /**
         * Used by Statement to execute a query or update sql statement. Should
         * never be called directly.
         **/
        public function executeQuery(statement:Statement, sql:String):void
        {
        	_tx = 0;
        	_queryStart = getTimer();
            setDataHandler(new QueryHandler(this, statement));
            sendCommand(Mysql.COM_QUERY, sql);
        }
        
        /**
        * Executes a binary query object as a sql statement. Should never be
        * called directly.
        **/
        public function executeBinaryQuery(statement:Statement, query:BinaryQuery):void
        {
        	setDataHandler(new QueryHandler(this, statement));
        	sendBinaryCommand(Mysql.COM_QUERY, query);
        }
        
        private function sendBinaryCommand(command:int, data:BinaryQuery):void
        {
            var packet:Packet = new Packet();
            packet.writeByte(command);
            data.readBytes( packet, packet.position, data.bytesAvailable );
            packet.send(sock);
        }
		
		private function sendCommand(command:int, data:String):void
        {
            var packet:Packet = new Packet();
            packet.writeByte(command);
            packet.writeUTFBytes(data);
            packet.send(sock);
        }
        
        /**
        * Changes the database
        **/
        public function changeDatabaseTo(whatDb:String, doNotChangeHandler:Boolean=false):void
        {	
        	if ( doNotChangeHandler == false ) {
        		setDataHandler(new CommandHandler(this));
        	}
        	
            if ( whatDb == null || whatDb.length == 0 )
                return;
                
            sendCommand(Mysql.COM_INIT_DB, whatDb);
        }
        
        /**
        * Returns the number of bytes recieved since the last query
        **/
        public function get tx():Number {
        	return _tx;
        }
        
        /**
        * Returns the number of bytes recieved since the connection was opened
        **/
        public function get totalTX():Number {
        	return _totalTX;
        }
        
        /**
        * Returns the time the last query was executed
        **/
        public function get lastQueryStart():Number {
        	return _queryStart;
        }
        
        /**
        * Returns the actual socket.
        **/
        public function getSocket():Socket
        {
        	return sock;
        }
	}
}