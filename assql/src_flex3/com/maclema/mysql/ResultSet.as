package com.maclema.mysql
{
    import flash.utils.ByteArray;
    
    import mx.collections.ArrayCollection;
    
    public class ResultSet
    {
        /**
         * Used by Connection when building the ResultSet, should never
         * be called directly
         **/
        public static function addColumn(rs:ResultSet, column:Field):void
        {
            rs.columns.push(column);
        }
        
        /**
         * Used by Connection when building the ResultSet, should never
         * be called directly
         **/
        public static function addRow(rs:ResultSet, row:Array):void
        {
            rs.rows.push(row);
        }
        
        /**
         * Used by Connection when building the ResultSet, should never
         * be called directly
         **/
        public static function initialize(rs:ResultSet):void
        {
            rs.nameMap = new Object();
            for ( var i:int=0; i<rs.columns.length; i++ )
            {
                var c:Field = Field(rs.columns[i]);
                rs.nameMap[c.getName()] = (i+1);
            }
        }
        
        private var index:int = -1;
        private var columns:Array;
        private var rows:Array;
        private var nameMap:Object;
        
        public function ResultSet()
        {
            this.columns = new Array();
            this.rows = new Array();    
        }
        
        /**
         * Returns the number of columns in the ResultSet
         **/
        public function get numColumns():int
        {
            return columns.length;
        }
        
        /**
         * Advances the pointer to the next row
         **/
        public function next():Boolean
        {
            if ( index < rows.length-1 )
            {
                index++;
                return true;
            }
            
            return false;
        }
        
        /**
         * Moves the pointer to the first row
         **/
        public function first():Boolean
        {
            if ( rows.length == 0 )
            {
                index = -1;
                return false;
            }
            
            index = 0;
            return true;
        }
        
        /**
         * Moves the pointer to the last row.
         **/
        public function last():Boolean
        {
            if ( rows.length == 0 )
            {
                index = -1;
                return false;
            }
            
            index = rows.length;
            return true;
        }
        
        /**
         * Returns a String value from the specified column. You may specify
         * columns using a 1-based number or the column name
         **/
        public function getString(column:*):String
        {
        	var data:ByteArray = getBinary(column);
        	if ( data == null ) {
        		return null;
        	}
        	data.position = 0;
        	return data.readUTFBytes(data.bytesAvailable);
        }
        
        /**
         * Returns an int for the specifiec column
         **/
        public function getInt(column:*):int
        {
            return int(getString(column));
        }
        
        /**
         * Returns a Number for the specifiec column
         **/
        public function getNumber(column:*):Number
        {
            return Number(getString(column));
        }
        
        /**
         * Returns a Date object for the specified column
         **/
        public function getDate(column:*):Date
        {
            var dateString:String = getString(column);
            
            if ( dateString == null ) {
            	return null;
            }
            
            var pat:RegExp = /-/g;
            dateString = dateString.replace(pat, "/");

            return new Date( Date.parse(dateString) );
        }
        
        /**
         * Returns a binary ByteArray for the specified column
         **/
        public function getBinary(column:*):ByteArray
        {
            var colIndex:int;
        	
        	if ( column is Number || column is int || column is uint )
        	{
        		colIndex = int(column);
        	}
        	else if ( column is String )
        	{
        		colIndex = int(nameMap[String(column)]);
        	}
        	else
        	{
        		throw new Error("Can only select columns using their name or index");
        	}
        	
        	colIndex -= 1; //columns are 1-based
        	
        	return ByteArray(rows[index][colIndex]);
        }
        
        /**
         * Returns all rows as a bindable ArrayCollection
         **/
        public function getRows():ArrayCollection
        {
        	var ac:ArrayCollection = new ArrayCollection();
        	while ( this.next() ) {
        		var obj:Object = new Object();
        		var index:int = 0;
        		for ( var prop:String in this.nameMap ) {
        			index++;
        			obj[prop] = getString(prop);
        			obj[index] = getString(prop);
        		}
     			ac.addItem(obj);
        	}
        	this.index = -1;
        	
            return ac;
        }
        
        /**
         * Returns an array for Field objects
         **/
        public function getColumns():Array
        {
            return columns;
        }
        
        /**
        * Returns the number of rows in the ResultSet
        **/
        public function size():int {
        	return rows.length;
        }
    }
}