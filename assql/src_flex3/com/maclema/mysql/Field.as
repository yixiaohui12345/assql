package com.maclema.mysql
{
	/**
	 * This class represents a MySql column
	 **/
    public class Field
    {
        /*
         VERSION 4.1
         Bytes                      Name
         -----                      ----
         n (Length Coded String)    catalog
         n (Length Coded String)    db
         n (Length Coded String)    table
         n (Length Coded String)    org_table
         n (Length Coded String)    name
         n (Length Coded String)    org_name
         1                          (filler)
         2                          charsetnr
         4                          length
         1                          type
         2                          flags
         1                          decimals
         2                          (filler), always 0x00
         n (Length Coded Binary)    default
        */
        private var _catalog:String;
        private var _db:String;
        private var _table:String;
        private var _orgTable:String;
        private var _name:String;
        private var _orgName:String;
        private var _charsetnr:int;
        private var _length:int;
        private var _type:int;
        private var _flags:int;
        private var _decimals:int;
        
        public function Field(packet:Packet)
        {
            _catalog = packet.readLengthCodedString();
            _db = packet.readLengthCodedString();
            _table = packet.readLengthCodedString();
            _orgTable = packet.readLengthCodedString();
            _name = packet.readLengthCodedString();
            _orgName = packet.readLengthCodedString();
            packet.readByte(); //filler
            _charsetnr = packet.readTwoByteInt();
            _length = packet.readInt();
            _type = packet.readByte();
            _flags = packet.readTwoByteInt();
            _decimals = packet.readByte();
        }
        
        /**
         * Catalog. For 4.1, 5.0 and 5.1 the value is "def".
         **/
        public function getCatalog():String
        {
            return _catalog;
        }
        
        /**
         * Database identifier
         **/
        public function getDatabase():String
        {
            return _db;
        }
        
        /**
         * The table identifier after the AS clause
         **/
        public function getTable():String
        {
            return _table;
        }
        
        /**
         * Original table identifier
         **/
        public function getRealTable():String
        {
            return _orgTable;
        }
        
        /**
         * Column identifier after AS clase
         **/
        public function getName():String
        {
            return _name;
        }
        
        /**
         * Original column identifier
         **/
        public function getRealName():String
        {
            return _orgName;
        }
        
        /**
         * Character set number
         **/
        public function getCharacterSet():int
        {
            return _charsetnr;
        }
        
        /**
         * Length of column, according to the definition.
         * Also known as "display length". The value given
         * here may be larger than the actual length, for
         * example an instance of a VARCHAR(2) column may
         * have only 1 character in it.
         **/
        public function getLength():int
        {
            return _length;
        }
        
        /**
         * The code for the column's data type
         **/
        public function getType():int
        {
            return _type;
        }
        
        /**
         * Possible flag values
         **/
        public function getFlags():int
        {
            return _flags;
        }
        
        /**
         * The number of positions after the decimal point
         **/
        public function getDecimals():int
        {
            return _decimals;
        }
    }
}