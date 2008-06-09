package model
{
	import com.maclema.MyConnections;
	import com.maclema.mysql.Connection;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class Model
	{
		private static var instance:Model;
		
		public static function getInstance():Model {
			if ( instance == null ) {
				instance = new Model();
			}
			return instance;
		}
		
		[Bindable]
		public var connections:ArrayCollection;
		
		[Bindable]
		public var myConnections:MyConnections;
		
		public function Model()
		{
			if ( instance != null ) {
				throw new Error("Singleton");
			}
			
			connections = new ArrayCollection();
			myConnections = new MyConnections();
		}
		
		private function hasConnection(name:String):Boolean {
			for ( var i:int=0; i<connections.length; i++ ) {
				if ( connections[i].name == name ) {
					return true;
				}
			}
			return false;
		}
		
		public function newConnection(name:String, hostname:String, port:int, username:String, password:String, database:String):Connection {
			var con:Connection;
			
			if ( hasConnection(name) ) {
				throw new Error("Connection already exists");
			}
			else {
				con = new Connection(hostname, port, username, password, database);
				con.addEventListener(Event.CLOSE, onDisconnect);
				connections.addItem({name: name, con: con});
			}
			
			return con;
		}
		
		private function onDisconnect(e:Event):void {
			var con:Connection = Connection(e.target);
			for ( var i:int=connections.length-1; i>=0; i-- ) {
				if ( connections.getItemAt(i).con == con ) {
					connections.removeItemAt(i);
					return;
				}
			}
		}
		
		public function getConnection(name:String):Connection {
			for ( var i:int=0; i<connections.length; i++ ) {
				if ( connections[i].name == name ) {
					return connections[i].con;
				}
			}
			return null;
		}
	}
}