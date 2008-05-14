package com.maclema
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	
	public class MyConnections
	{
		private static var instance:MyConnections;
		
		public static function getInstance():MyConnections {
			if ( instance == null ) {
				instance = new MyConnections();
			}
			return instance;
		}
		
		[Bindable]
		public var connections:ArrayCollection = new ArrayCollection();
		
		public function MyConnections()
		{
			if ( instance != null ) {
				throw new Error("Singleton!");
			}
			open();
		}
		
		private function open():void {
			var file:File = File.applicationStorageDirectory.resolvePath("connections.xml");
			if ( file.exists ) {
				var xml:XML;
				var fs:FileStream = new FileStream();
				fs.open(file, FileMode.READ);
				xml = XML(fs.readUTFBytes( fs.bytesAvailable ));
				fs.close();
				
				var cons:XMLList = xml.connection;
				for ( var i:int=0; i<cons.length(); i++ ) {
					var con:DBConn = new DBConn(cons[i]);
					this.connections.addItem(con);
				}
			}
		}
		
		public function save():void {
			var xml:XML = <assql-admin />;
			
			for ( var i:int=0; i<this.connections.length; i++ ) {
				xml.appendChild( DBConn(this.connections[i]).toXML() );
			}
			
			var file:File = File.applicationStorageDirectory.resolvePath("connections.xml");
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeUTFBytes(xml.toXMLString());
			fs.close();
		}
	}
}