package com.maclema.mysql
{
	public class MySqlResponser
	{
		public var responseHandler:Function;
		public var errorHandler:Function;
		
		public function MySqlResponser(responseHandler:Function, errorHandler:Function)
		{
			this.responseHandler = responseHandler;
			this.errorHandler = errorHandler;
		}
	}
}