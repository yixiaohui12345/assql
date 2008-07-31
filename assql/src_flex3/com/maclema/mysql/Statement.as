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
        
        public var streamResults:Boolean = false;
        public var streamingInterval:int = 1000;
        
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
        	
        	if ( this.sql.indexOf("call") == 0 ) {
        		return executeCall();
        	}
        	
        	//parameters
        	if ( this.sql.indexOf("?") != -1 ) {
        		Logger.info(this, "executing a statement with parameters");
        		var binq:BinaryQuery = addParametersToSql();
        		con.executeBinaryQuery(this, token, binq);
        	}
        	else {
        		Logger.info(this, "executing a regular statement");
          		con.executeQuery(this, token, sql);
         	}
         	
         	return token;
        }
        
        private function dispatchCallToken(callResultSet:ResultSet, callResponse:MySqlResponse, callParams:MySqlOutputParams, publicToken:MySqlToken):void {
        	if ( callResultSet != null ) {
        		Logger.debug(this, "Dispatching Call ResultSet");
        		
        		var evt:MySqlEvent = new MySqlEvent(MySqlEvent.RESULT);
        		evt.resultSet = callResultSet;
        		publicToken.dispatchEvent(evt);
        	}
        	
        	if ( callResponse != null ) {
        		Logger.debug(this, "Dispatching Call Response");
        		
        		var evt:MySqlEvent = new MySqlEvent(MySqlEvent.RESPONSE);
        		evt.affectedRows = callResponse.affectedRows;
        		evt.insertID = callResponse.insertID;
        		publicToken.dispatchEvent(evt);
        	}
        	
        	if ( callParams != null ) {
        		Logger.debug(this, "Dispatching Call Parameters");
        		
        		var evt:MySqlEvent = new MySqlEvent(MySqlEvent.PARAMS);
        		evt.params = callParams;
        		publicToken.dispatchEvent(evt);
        	}
        }
        
        private function executeCall():MySqlToken {
        	var publicToken:MySqlToken = new MySqlToken();
        	
        	var callResultSet:ResultSet;
        	var callResponse:MySqlResponse;
        	var callParams:MySqlOutputParams;
        	
        	//handles getting call output parameters if any are defined
        	var callParamsToken:MySqlToken = new MySqlToken();
        	callParamsToken.addResponder(new Responder(
        		function(data:Object):void {
        			callParams = new MySqlOutputParams();
        			
        			ResultSet(data).next();
					for ( var param:String in outputParams ) {
						trace("Param '" + param + "': " + ResultSet(data).getString(param));
						callParams[param] = ResultSet(data).getString(param);
					}
					
					Logger.debug(this, "Got Output Parameters");
					dispatchCallToken(callResultSet, callResponse, callParams, publicToken);
        		},
        		function(info:Object):void {
        			ErrorHandler.handleError(info.id, info.msg, publicToken);
        		}
        	));
        	
        	//handles getting the response object if the procedure returns a resultset.
        	var callResponseToken:MySqlToken = new MySqlToken();
        	callResponseToken.addResponder(new Responder(
        		function(data:Object):void {
        			callResponse = new MySqlResponse();
        			callResponse.affectedRows = data.affectedRows;
        			callResponse.insertID = data.insertID;
        			
        			Logger.debug(this, "Got Response.");
        			
        			if ( hasOutputParams ) {
        				Logger.debug(this, "Waiting For Call Output Parameters");
        				con.executeQuery(null, callParamsToken, getSelectParamsSql());
    				}
    				else {
    					dispatchCallToken(callResultSet, callResponse, callParams, publicToken);
    				}
        		},
        		function(info:Object):void {
        			ErrorHandler.handleError(info.id, info.msg, publicToken);
        		}
        	));
        	
        	//handles the first procedure response
        	var callToken:MySqlToken = new MySqlToken();
        	callToken.addResponder(new Responder(
        		function(data:Object):void {
        			if ( data is ResultSet ) {
        				Logger.debug(this, "Call Returned a ResultSet, Waiting for Response too.");
        				callResultSet = ResultSet(data);
        				con.setDataHandler(new QueryHandler(con.instanceID, callResponseToken));
        			}
        			else {
        				callResponse = new MySqlResponse();
        				callResponse.affectedRows = data.affectedRows;
        				callResponse.insertID = data.insertID;
        				
        				if ( hasOutputParams ) {
        					Logger.debug(this, "Waiting For Call Output Parameters");
        					con.executeQuery(null, callParamsToken, getSelectParamsSql());
        				}
        				else {
        					dispatchCallToken(callResultSet, callResponse, callParams, publicToken);
        				}
        			}
        		},
        		function(info:Object):void {
        			ErrorHandler.handleError(info.id, info.msg, publicToken);
        		}
        	));
        	
        	Logger.debug(this, "Executing Call (" + this.sql + ")");
        	con.executeQuery(this, callToken, sql);
        	
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
        	con.executeBinaryQuery(this, token, query);
        	
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