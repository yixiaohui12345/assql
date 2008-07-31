package com.maclema.mysql
{
    import com.maclema.logging.Logger;
    import com.maclema.mysql.events.MySqlEvent;
    
    import flash.utils.ByteArray;
    
    import mx.formatters.DateFormatter;
    import mx.rpc.Responder;
    import mx.utils.StringUtil;
    
    /**
    * The Statement class allows you to execute queries for the MySql connection.
    **/
    public class Statement
    {
        private var con:Connection;
        private var _sql:String = null;
        private var params:Array;
        private var outputParams:Object;
        private var hasOutputParams:Boolean = false;
        
        /**
        * Constructs a new Statement object. Should never be called directly, rather, use Connection.createStatement();
        **/
        public function Statement(con:Connection)
        {
            this.con = con;
            this.params = new Array();
            this.outputParams = {};
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
        
        public function registerOutputParam(param:String):void {
        	outputParams[param] = null;
        	hasOutputParams = true;
        }
        
        public function getString(param:String):String {
        	return outputParams[param];
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
        	
        	if ( hasOutputParams ) {
        		return executeQueryWithOutParams(sqlString);
        	}
        	
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
        
        private function executeQueryWithOutParams(sqlString:String=null):MySqlToken {
        	Logger.info(this, "executeQueryWithOutParams");
        	
        	var publicToken:MySqlToken = new MySqlToken();
        	var internalToken:MySqlToken = new MySqlToken();
        	
        	if ( sqlString != null ) {
        		this.sql = StringUtil.trim(sqlString);
        	}
        	
        	//watch our internal token, when we get our results, grab our output parameters.
        	internalToken.addResponder(new Responder(
        		function(internalTokenData:Object):void {
        			var st_params:Statement = con.createStatement();
        			var token_params:MySqlToken = new MySqlToken();
        			con.executeQuery(token_params, getSelectParamsSql());
        			token_params.addResponder(new Responder(
        				function(paramsData:Object):void {
        					if ( paramsData is ResultSet ) {
	        					ResultSet(paramsData).next();
	        					for ( var param:String in outputParams ) {
	        						outputParams[param] = ResultSet(paramsData).getString(param);
	        					}
        					}
        					
        					var evt:MySqlEvent;
        					if ( internalTokenData is ResultSet ) {
        						evt = new MySqlEvent(MySqlEvent.RESULT);
        						evt.resultSet = ResultSet(internalTokenData);
        					}
        					else {
        						evt = new MySqlEvent(MySqlEvent.RESPONSE);
        						evt.affectedRows = internalTokenData.affectedRows;
        						evt.insertID = internalTokenData.insertID;
        					}
        					publicToken.dispatchEvent(evt);
        				},
        				function(info:Object):void {
        					ErrorHandler.handleError(info.id, info.msg, publicToken);
        				}
        			));
        		},
        		function(info:Object):void {
        			ErrorHandler.handleError(info.id, info.msg, publicToken);
        		}
        	));
        	//parameters
        	if ( this.sql.indexOf("?") != -1 ) {
        		Logger.info(this, "executing a statement with parameters");
        		var binq:BinaryQuery = addParametersToSql();
        		con.executeBinaryQuery(internalToken, binq);
        	}
        	else {
        		Logger.info(this, "executing a regular statement");
          		con.executeQuery(internalToken, sql);
         	}
         	
         	return publicToken;
        }
        
        private function getSelectParamsSql():String {
        	var sql:String = "SELECT ";
        	for ( var param:String in outputParams ) {
        		sql += param + ",";
        	}
        	sql = sql.substr(0, sql.length-1);
        	return sql;
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