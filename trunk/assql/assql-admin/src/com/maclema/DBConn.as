package com.maclema
{
	[Bindable]
	public class DBConn
	{
		public var connectionName:String = "";
		
		public var hostname:String = "";
		public var port:int = 3306;
		public var username:String = "";
		public var password:String = "";
		public var database:String = "";
		
		public function DBConn(xml:XML=null)
		{
			if ( xml != null ) {
				this.connectionName = String(xml.connectionName);
				this.hostname = String(xml.hostname);
				this.port = int(xml.port);
				this.username = String(xml.username);
				this.password = String(xml.password);
				this.database = String(xml.database);
			}
		}
		
		public function toXML():XML {
			var xml:XML = <connection />;
			xml.connectionName = this.connectionName;
			xml.hostname = this.hostname;
			xml.port = this.port;
			xml.username = this.username;
			xml.password = this.password;
			xml.database = this.database;
			return xml;
		}
	}
}