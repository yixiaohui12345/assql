package com.maclema.mysql
{
    import com.maclema.mysql.events.MySqlErrorEvent;
    import com.maclema.mysql.events.MySqlEvent;
    
    import flash.events.EventDispatcher;
    import flash.utils.ByteArray;
    
    [Event(name="sqlError", type="com.maclema.mysql.events.MySqlErrorEvent")]
    [Event(name="sql_response", type="com.maclema.mysql.events.MySqlEvent")]
    [Event(name="sql_result", type="com.maclema.mysql.events.MySqlEvent")]
    public class Statement extends EventDispatcher
    {
        private var con:Connection;
        private var _sql:String = null;
        private var params:Array;
        
        private var responder:MySqlResponser;
        
        public function Statement(con:Connection)
        {
            this.con = con;
            this.params = new Array();
            
            this.addEventListener(MySqlEvent.RESPONSE, handleResponse);
            this.addEventListener(MySqlEvent.RESULT, handleResponse);
            this.addEventListener(MySqlErrorEvent.SQL_ERROR, handleError);
        }
        
        private function handleResponse(e:MySqlEvent):void {
        	if ( this.responder != null ) {
        		if ( this.responder.responseHandler != null ) {
        			this.responder.responseHandler(e);
        		}
        	}
        }
        
        private function handleError(e:MySqlErrorEvent):void {
        	if ( this.responder != null ) {
        		if ( this.responder.errorHandler != null ) {
        			this.responder.errorHandler(e);
        		}
        	}
        }
        
        /**
        * Set the sql string to execute
        **/
        public function set sql(value:String):void {
        	this._sql = value;
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
        	params[index] = value;
        }
        
        /**
        * Set a Number parameter
        **/
        public function setNumber(index:int, value:Number):void {
        	params[index] = value;
        }
        
        /**
        * Set a Date parameter
        **/
        public function setDate(index:int, value:Date):void {
        	params[index] = value;
        }
        
        /**
        * Set's a Binary parameter
        **/
        public function setBinary(index:int, value:ByteArray):void {
        	params[index] = value;
        }
        
        /**
         * Executes the specified sql statement
         **/
        public function executeQuery(sqlString:String=null, responder:MySqlResponser=null):void
        {
        	this.responder = responder;
        	
        	if ( sqlString != null ) {
        		this.sql = sqlString;
        	}
        	
        	//parameters
        	if ( this.sql.indexOf("?") != -1 ) {
        		var binq:BinaryQuery = addParametersToSql();
        		con.executeBinaryQuery(this, binq);
        	}
        	else {
          		con.executeQuery(this, sql);
         	}
        }
        
        private function addParametersToSql():BinaryQuery {
        	var parts:Array = this.sql.split("?");
    		var binq:BinaryQuery = new BinaryQuery();
    		for ( var i:int = 0; i<parts.length; i++ ) {
    			binq.append(parts[i]);
    			
    			if ( params[i+1] ) {
    				var value:* = params[i+1];
    				
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
    					throw new Error("Unknown Parameter Object For Parameter Index " + i);
    				}
    			}
    		}
    		return binq;
        }
        
        /**
        * Executes a binary query object
        **/
        public function executeBinaryQuery(query:BinaryQuery, responder:MySqlResponser=null):void
        {
        	this.responder = responder;
        	
        	query.position = 0;
        	con.executeBinaryQuery(this, query);
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