package com.maclema.mysql
{
    import flash.utils.ByteArray;
    import com.adobe.crypto.SHA1;
    import mx.core.IDataRenderer;
    import flash.utils.IDataOutput;
    import flash.utils.IDataInput;
    
    public class Util
    {
    	/**
    	 * Handles the new encryption for 4.1 and newer servers.
    	 **/
        public static function newCrypt(password:String, seed:String):String
        {
            var i:int;
            var b:Number;
            var d:Number;
    
            if ((password == null) || (password.length == 0)) 
            {
                return password;
            }
    
            var pw:Array = newHash(seed);
            var msg:Array = newHash(password);
            var max:Number = 0x3fffffff;
            var seed1:Number = (pw[0] ^ msg[0]) % max;
            var seed2:Number = (pw[1] ^ msg[1]) % max;
            var chars:Array = new Array(seed.length);
    
            for (i = 0; i < seed.length; i++) 
            {
                seed1 = ((seed1 * 3) + seed2) % max;
                seed2 = (seed1 + seed2 + 33) % max;
                d = seed1 / max;
                b = Math.floor((d * 31) + 64);
                chars[i] = b;
            }
    
            seed1 = ((seed1 * 3) + seed2) % max;
            seed2 = (seed1 + seed2 + 33) % max;
            d = seed1 / max;
            b = Math.floor(d * 31);
    
            for (i = 0; i < seed.length; i++) 
            {
                chars[i] ^= b;
            }
            
            var ret:String = "";
            
            for ( i; i<chars.length; i++ )
            {
                ret += String.fromCharCode( chars[i] );
            }
    
            return ret;
        }
        
        private static function newHash(password:String):Array
        {
            var nr:Number = 1345345333;
            var add:Number = 7;
            var nr2:Number = 0x12345671;
            var tmp:Number;

            for (var i:int = 0; i < password.length; ++i)
            {
                if ((password.charAt(i) == ' ') || (password.charAt(i) == '\t')) 
                {
                    continue; // skip spaces
                }
    
                tmp = ( 0xff & password.charCodeAt(i) );
                nr ^= ((((nr & 63) + add) * tmp) + (nr << 8));
                nr2 += ((nr2 << 8) ^ nr);
                add += tmp;
            }
            
            var result:Array = new Array(2);
            result[0] = nr & 0x7fffffff;
            result[1] = nr2 & 0x7fffffff;

            return result;
        }
        
        /**
        * Handles the 4.1 or newer encryption
        **/
        public static function scramble411(password:String, seed:String):ByteArray
        {
            var passwordHashStage1:ByteArray = SHA1.hashToByteArray(password);
            var passwordHashStage2:ByteArray = SHA1.hashBytesToByteArray(passwordHashStage1);
            
            passwordHashStage2.position=0;
            var stage2string:String = passwordHashStage2.readUTFBytes(passwordHashStage2.bytesAvailable);
            
            var passwordHashStage3:ByteArray = SHA1.hashToByteArray(seed+stage2string);
            
            var toBeXord:ByteArray = new ByteArray();
            
            var numToXor:int = passwordHashStage3.length; 
            
            passwordHashStage3.position=0;
            passwordHashStage1.position=0;
            for ( var i:int=0; i<numToXor; i++ )
            {
                var char1:int = passwordHashStage3.readByte();
                var char2:int = passwordHashStage1.readByte();
                var newChar:int = char1 ^ char2;
                
                toBeXord.writeByte(newChar);
            }
            
            toBeXord.position = 0;
            
            return toBeXord;
        }
    }
}