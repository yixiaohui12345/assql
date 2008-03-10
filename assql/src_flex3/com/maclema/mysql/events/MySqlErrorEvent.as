package com.maclema.mysql.events
{
    import flash.events.Event;
    import flash.events.ErrorEvent;

    public class MySqlErrorEvent extends ErrorEvent
    {
        public static const SQL_ERROR:String = "sqlError";
        
        public var msg:String;
        public var id:int;
        public function MySqlErrorEvent(msg:String, id:int=0)
        {
            super(SQL_ERROR);
            this.msg = msg;
            this.id = id;
            this.text = "SQL Error #" + id + ": " + msg;
        }
    }
}