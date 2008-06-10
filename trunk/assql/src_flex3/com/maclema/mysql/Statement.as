package com.maclema.mysql
{
    import com.maclema.logging.Logger;
    
    import flash.utils.ByteArray;
    
    import mx.formatters.DateFormatter;
    import mx.utils.StringUtil;
    
    /**
    * The Statement class allows you to execute queries for the MySql connection.
    **/
    public class Statement
    {
        private var con:Connection;
        private var _sql:String = null;
        private var params:Array;
        
        /**
        * Constructs a new Statement object. Should never be called directly, rather, use Connection.createStatement();
        **/
        public function Statement(con:Connection)
        {
            this.con = con;
            this.params = new Array();
        }
        
        
        /**
        * Set the sql string to execute
        **/
        public function set sql(value:String):void {
        	this._sql = StringUtil.trim(value);
        }
        
        /**
        * Get the sql string to execute
        **/
        public function get sql():String {
        	return this._sql;
        }
        
        /**
        * Set a String parameter
        **/
        public function setString(index:int, value:String):void {
        	Logger.info(this, "setString (" + value + ")");
        	params[index] = value;
        }
        
        /**
        * Set a Number parameter
        **/
        public function setNumber(index:int, value:Number):void {
        	Logger.info(this, "setNumber (" + value +")");
        	params[index] = value;
        }
        
        /**
        * Set a Date parameter (YYYY-MM-DD)
        **/
        public function setDate(index:int, value:Date):void {
        	Logger.info(this, "setDate ("+ value.toDateString() +")");
        	var df:DateFormatter = new DateFormatter();
        	df.formatString = "YYYY-MM-DD";
        	params[index] = df.format(value);
        }
        
        /**
        * Set a DateTime parameter (YYYY-MM-DD J:NN:SS)
        **/
        public function setDateTime(index:int, value:Date):void {
        	Logger.info(this, "setDate ("+ value.toDateString() +")");
        	var df:DateFormatter = new DateFormatter();
        	df.formatString = "YYYY-MM-DD J:NN:SS";
        	params[index] = df.format(value);
        }
        
       /**
        * Set a Time parameter (H:MM:SS)
        **/
        public function setTime(index:int, value:Date):void {
        	Logger.info(this, "setDate ("+ value.toDateString() +")");
        	var df:DateFormatter = new DateFormatter();
        	df.formatString = "J:NN:SS";
        	params[index] = df.format(value);
        }
        
        /**
        * Set's a Binary parameter
        **/
        public function setBinary(index:int, value:ByteArray):void {
        	Logger.info(this, "setBinary (" + value.length + " bytes)");
        	params[index] = value;
        }
        
        /**
         * Executes the specified sql statement. The statement can be provided using either the sql property
         * or as the first parameter of this method. You may also specify a IResponder object as the second parameter.
         * <br><br>
         * When result(data:Object) is called on the IResponder the data object will be either a ResultSet, in the case
         * of query statements, and in the case of data manipulation statements, will be an object with two properties, 
         * affectedRows, and insertID. 
         **/
        public function executeQuery(sqlString:String=null):MySqlToken
        {
        	Logger.info(this, "executeQuery");
        	
        	var token:MySqlToken = new MySqlToken();
        	
        	if ( sqlString != null ) {
        		this.sql = StringUtil.trim(sqlString);
        	}
        	
        	//parameters
        	if ( this.sql.indexOf("?") != -1 ) {
        		Logger.info(this, "executing a statement with parameters");
        		var binq:BinaryQuery = addParametersToSql();
        		con.executeBinaryQuery(token, binq);
        	}
        	else {
        		Logger.info(this, "executing a regular statement");
          		con.executeQuery(token, sql);
         	}
         	
         	return token;
        }
        
        private function addParametersToSql():BinaryQuery {
        	var parts:Array = this.sql.split("?");
    		var binq:BinaryQuery = new BinaryQuery(con.connectionCharSet);
    		for ( var i:int = 0; i<parts.length; i++ ) {
    			binq.append(parts[i]);
    			
    			if ( params[i+1] ) {
    				var value:* = params[i+1];
    				
    				binq.append("'");
    				if ( value is String ) {
    					binq.append(value, true);
    				}
    				else if ( value is int || value is Number ) {
    					binq.append(String(value));
    				}
    				else if ( value is Date ) {
    					binq.append(String((value as Date).getTime()));
    				}
    				else if ( value is ByteArray ) {
    					binq.appendBinary(ByteArray(value));
    				}
    				else {
    					Logger.fatal(this, "Unknown parameter objject for parameter index " + i);
    					throw new Error("Unknown Parameter Object For Parameter Index " + i);
    				}
    				binq.append("'");
    			}
    		}
    		return binq;
        }
        
        /**
        * Executes a binary query object
        **/
        internal function executeBinaryQuery(query:BinaryQuery):MySqlToken
        {
        	Logger.info(this, "executeBinaryQuery");
        	
        	var token:MySqlToken = new MySqlToken();
        	
        	query.position = 0;
        	con.executeBinaryQuery(token, query);
        	
        	return token;
        }
        
        /**
         * Returns the Connection that created this statement
         **/
        public function getConnection():Connection
        {
            return con;
        }
    }
}