package com.maclema.mysql
{
    import flash.events.EventDispatcher;
    
    [Event(name="sqlError", type="com.maclema.mysql.MySqlErrorEvent")]
    [Event(name="sql_response", type="com.maclema.mysql.MySqlEvent")]
    [Event(name="sql_result", type="com.maclema.mysql.MySqlEvent")]
    public class Statement extends EventDispatcher
    {
        private var con:Connection;
        
        public function Statement(con:Connection)
        {
            this.con = con;
        }
        
        /**
         * Executes the specified sql statement
         **/
        public function executeQuery(sql:String):void
        {
            con.executeQuery(this, sql);
        }
        
        /**
        * Executes a binary query object
        **/
        public function executeBinaryQuery(query:BinaryQuery):void
        {
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