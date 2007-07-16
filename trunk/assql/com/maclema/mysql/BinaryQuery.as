package com.maclema.mysql
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	/**
	 * This class is used to build SQL quries that include binary data such as
	 * files or images.
	 **/
	public class BinaryQuery extends Buffer
	{
		public function BinaryQuery()
		{
			super();
		}
		
		/**
		 * Appends a string value to the query. If escape is set to true
		 * the string will be escaped before appended to the query.
		 **/
		public function append(str:String, escape:Boolean=false):void
		{
			if ( !escape )
			{
				writeUTFBytes(str);
			}
			else
			{
				writeUTFBytes( Mysql.escapeString(str) );
			}
		}
		
		/**
		 * Appends a chunk of binary data to the query to be executed
		 **/
		public function appendBinary(data:IDataInput):void
		{
			while ( data.bytesAvailable > 0 )
			{
				var byte:int = data.readByte() & 0xFF;
				
				if ( byte == 0x27 )
				{
					writeByte( 0x5C );
				}	
				else if ( byte == 0x22 )
				{
					writeByte( 0x5C );
				}
				else if ( byte == 0x5C )
				{
					writeByte( 0x5C );
				}
				
				writeByte( byte );
			}
		}
	}
}