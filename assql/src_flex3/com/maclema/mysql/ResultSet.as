package com.maclema.mysql
{
    import com.maclema.logging.Logger;
    
    import flash.utils.ByteArray;
    import flash.utils.getTimer;
    
    import mx.collections.ArrayCollection;
    import mx.formatters.DateFormatter;
    
    /**
    * The ResultSet class represents a data set retuends by MySql for a query.
    **/
    public class ResultSet
    {        
        private var _token:MySqlToken;
        
        private var index:int = -1;
        private var columns:Array;
        private var rows:Array;
        private var map:Object;
        
        private var charSet:String = "";
        
        private var todayDateString:String;
        
        /**
        * Constructs a new ResultSet object
        **/
        public function ResultSet(token:MySqlToken)
        {
        	this._token = token;
            this.columns = new Array();
            this.rows = new Array();    
            
            //for getTime optimization
            var df:DateFormatter = new DateFormatter();
            df.formatString = "YYYY/MM/DD";
            todayDateString = df.format(new Date());
        }
        
        internal function initialize(charSet:String):void {
        	charSet = charSet;
        	
            map = new Object();
            for ( var i:int=0; i<columns.length; i++ )
            {
                var c:Field = Field(columns[i]);
                map[c.getName()] = i;
                map[String((i+1))] = i;
            }
        }
        
        internal function addColumn(field:Field):void {
        	this.columns[this.columns.length] = field;
        }
        
        internal function addRow(row:Array):void {
        	this.rows[this.rows.length] = row;
        }
        
        /**
        * Returns the token object that created this result set.
        **/
        public function get token():MySqlToken {
        	return _token;
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
         * Moves the pointer to the previous row
         **/
        public function previous():Boolean
        {
            if ( index > 0 )
            {
                index--;
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
            
            index = rows.length-1;
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
        	return data.readMultiByte(data.bytesAvailable, charSet);
        }
        
        /**
         * Returns an int for the specifiec column
         **/
        public function getInt(column:*):int
        {
            return int(getString(column));
        }
        
        /**
        * Returns a boolean value for the specified column.
        **/
        public function getBoolean(column:*):Boolean 
        {
        	return Boolean(getString(column));
        }
        
        /**
        * Returns a Date object, where yyyy-mm-dd is always the current date, but
        * the time values are HH:mm:ss from the column
        **/
        public function getTime(column:*):Date {
        	var timeString:String = getString(column);
            
            if ( timeString == null ) {
            	return null;
            }
			
			return new Date(Date.parse(todayDateString + " " + timeString));
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
        
            var mainParts:Array = dateString.split(" ");
            var dateParts:Array = mainParts[0].split("-");
            
            //check for 0000-00-00 dates
            if ( Number(dateParts[0])+Number(dateParts[1])+Number(dateParts[2]) == 0 ) {
            	return null;
            }
            
            return new Date(Date.parse(dateParts.join("/")+(mainParts[1]?" "+mainParts[1]:" ")));
        }
        
        /**
         * Returns a binary ByteArray for the specified column
         **/
        public function getBinary(column:*):ByteArray
        {
        	return ByteArray(rows[index][int(map[String(column)])]);
        }
        
        /**
         * Returns all rows as a bindable ArrayCollection, you can optionally pass a single
         * boolean value indicating if date's and time's should just be casted to plain strings.
         * Casting to plain strings is a lot faster then parsing the dates.
         **/
		public function getRows(dateTimesAsStrings:Boolean=false):ArrayCollection
		{
			var st:Number = getTimer();
			
			var oldIndex:int = index;
			
			index = -1;
			
			var arr:Array = new Array();
			while ( this.next() ) {
				var obj:Object = new Object();
				
				columns.forEach(function(c:Field, index:int, arr:Array):void {
					obj[c.getName()] = getCastedValue(c, dateTimesAsStrings);
				});
				
		 		arr.push(obj);
			}
			
			index = oldIndex;
			
			var run:Number = getTimer()-st;
			Logger.debug(this, "getRows() in " + run + " ms");
		    return new ArrayCollection(arr);
		}
        
        private function getCastedValue(field:Field, dateTimesAsStrings:Boolean):*
		{
			switch (field.getAsType())
			{
				case Mysql.AS3_TYPE_NUMBER:
					return getNumber(field.getName());
					
				case Mysql.AS3_TYPE_DATE:
					if ( dateTimesAsStrings ) { break; }
					return getDate(field.getName());
					
				case Mysql.AS3_TYPE_TIME:
					if ( dateTimesAsStrings ) { break; }
					return getTime(field.getName());
				
				case Mysql.AS3_TYPE_STRING:
					return getString(field.getName());
					
				case Mysql.AS3_TYPE_BYTEARRAY:
					return getBinary(field.getName());
			}
			return getString(field.getName());
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