#Examples of using asSQL (Beta 2.5 and later)

### On This Page ###
[MySqlService Example](Examples#MySqlService_Example.md)

[Token Responder Example 1](Examples#Token_Responder_Example_1.md)

[Token Responder Example 2](Examples#Token_Responder_Example_2.md)

[Inserting Binary Data Example](Examples#Inserting_Binary_Data_Example.md)

[Selecting Binary Data Example](Examples#Selecting_Binary_Data_Example.md)

[Stored Procedure Example](Examples#Stored_Procedure_Example.md)

[Streaming Results](Examples#Streaming_Results.md)


### MySqlService Example ###

This example is using MySqlService and DataGrid. The data grid's columns property and dataProvider property are bound to the MySqlService lastResult (ArrayCollection of Rows) and lastResultSet (The actual ResultSet).

```
<?xml version="1.0" encoding="utf-8"?>
<mx:WindowedApplication 
        xmlns:mx="http://www.adobe.com/2006/mxml" 
        xmlns:assql="com.maclema.mysql.mxml.*" 
        layout="absolute">
        
        <mx:Script>
        <![CDATA[
			import mx.controls.Alert;
			import com.maclema.mysql.events.MySqlErrorEvent;
	        import com.maclema.util.ResultsUtil;
	
	        private function handleConnected(e:Event):void {
	        	service.send("SELECT * FROM employees2 LIMIT 10");
	        }
	        
	        private function handleError(e:MySqlErrorEvent):void {
	        	Alert.show(e.text);
	        }
        ]]>
        </mx:Script>
        
        <assql:MySqlService id="service"
                hostname="localhost" 
                username="root"
                password=""
                database="assql-test"
                autoConnect="true"
                connect="handleConnected(event)" 
                sqlError="handleError(event)" />
                
        <mx:DataGrid id="grid" left="10" right="10" top="10" bottom="10"
                dataProvider="{service.lastResult}"
                columns="{ResultsUtil.getDataGridColumns(service.lastResultSet)}" />
                
</mx:WindowedApplication>
```


### Token Responder Example 1 ###

This is an example of using an AsyncResponder to handle a query.

```
import com.maclema.mysql.Statement;
import com.maclema.mysql.Connection;
import com.maclema.mysql.ResultSet;
import mx.controls.Alert;
import mx.rpc.AsyncResponder;
import com.maclema.mysql.MySqlToken;
import com.maclema.util.ResultsUtil;

//The MySql Connection
private var con:Connection;

private function onCreationComplete():void {
	con = new Connection("localhost", 3306, "root", "", "assql-test");
	con.addEventListener(Event.CONNECT, handleConnected);
	con.connect();
}

private function handleConnected(e:Event):void {
	var st:Statement = con.createStatement();
	
	var token:MySqlToken = st.executeQuery("SELECT * FROM employees");
	
	token.addResponder(new AsyncResponder(
		function(data:Object, token:Object):void {
			var rs:ResultSet = ResultSet(data);
			Alert.show("Found " + rs.size() + " employees!");
		},
		
		function(info:Object, token:Object):void {
			Alert.show("Error: " + info);
		},
		
		token
	));
}
```

### Token Responder Example 2 ###

This is a more in depth example. With each statement, an info property is set on the MySqlToken. This way all queries and responses can be handled with the same result and fault handlers. This example also uses a statement that uses parameters.

```
import com.maclema.mysql.Statement;
import com.maclema.mysql.Connection;
import com.maclema.mysql.ResultSet;
import mx.controls.Alert;
import mx.rpc.AsyncResponder;
import com.maclema.mysql.MySqlToken;
import com.maclema.util.ResultsUtil;

//The MySql Connection
private var con:Connection;

private function onCreationComplete():void {
	con = new Connection("localhost", 3306, "root", "", "assql-test");
	con.addEventListener(Event.CONNECT, handleConnected);
	con.connect();
}

private function handleConnected(e:Event):void {
	getAllEmployees();
}

private function getAllEmployees():void {
	var st:Statement = con.createStatement();
	
	var token:MySqlToken = st.executeQuery("SELECT * FROM employees");
	token.info = "GetAllEmployees";
	token.addResponder(new AsyncResponder(result, fault, token));
}

private function getEmployee(employeeID:int):void {
	var st:Statement = con.createStatement();
	st.sql = "SELECT * FROM employees WHERE employeeID = ?";
	st.setNumber(1, employeeID);
	
	var token:MySqlToken = st.executeQuery();
	token.info = "GetEmployee";
	token.employeeID = employeeID;
	token.addResponder(new AsyncResponder(result, fault, token));
}

private function result(data:Object, token:Object):void {
	var rs:ResultSet;
	
	if ( token.info == "GetAllEmployees" ) {
		rs = ResultSet(data);
		Alert.show("Found " + rs.size() + " employees!");	
	}
	else if ( token.info == "GetEmployee" ) {
		rs = ResultSet(data);
		if ( rs.next() ) {
			Alert.show("Employee " + token.employeeID + " username is '" + rs.getString("username") + "'");
		}
		else {
			Alert.show("No such employee for id " + token.employeeID);
		}
	}
}

private function fault(info:Object, token:Object):void {
	Alert.show(token.info + " Error: " + info);
}
```


### Inserting Binary Data Example ###

This is an example of inserting binary data.

```
import com.maclema.mysql.Statement;
import com.maclema.mysql.Connection;
import com.maclema.mysql.ResultSet;
import mx.controls.Alert;
import mx.rpc.AsyncResponder;
import com.maclema.mysql.MySqlToken;
import com.maclema.util.ResultsUtil;

//The MySql Connection
private var con:Connection;

private function onCreationComplete():void {
	con = new Connection("localhost", 3306, "root", "", "assql-test");
	con.addEventListener(Event.CONNECT, handleConnected);
	con.connect();
}

private function handleConnected(e:Event):void {
	//do something here
}

private function setEmployeePhoto(employeeID:int, photoFile:File):void {
	//the file bytes
	var filedata:ByteArray = new ByteArray();
	
	//read the file
	var fs:FileStream = new FileStream();
	fs.open(photoFile, FileMode.READ);
	fs.readBytes(filedata);
	fs.close();
	
	//execute the query
	var st:Statement = con.createStatement();
	st.sql = "UPDATE employees SET photo = ? WHERE employeeID = ?";
	st.setBinary(1, filedata);
	st.setNumber(2, employeeID);
	
	var token:MySqlToken = st.executeQuery();
	token.employeeID = employeeID;
	token.addResponder(new AsyncResponder(
		function (data:Object, token:Object):void {
			Alert.show("Employee " + token.employeeID + "'s photo updated! Affected Rows: " + data.affectedRows);
		},
		function (info:Object, token:Object):void {
			Alert.show("Error updating photo: " + info);
		},
		token
	));
}
```


### Selecting Binary Data Example ###

This is an example of selecting binary data.


```
import com.maclema.mysql.Statement;
import com.maclema.mysql.Connection;
import com.maclema.mysql.ResultSet;
import mx.controls.Alert;
import mx.rpc.AsyncResponder;
import com.maclema.mysql.MySqlToken;
import com.maclema.util.ResultsUtil;

//The MySql Connection
private var con:Connection;

private function onCreationComplete():void {
	con = new Connection("localhost", 3306, "root", "", "assql-test");
	con.addEventListener(Event.CONNECT, handleConnected);
	con.connect();
}

private function handleConnected(e:Event):void {
	//do something here
}

private function getEmployeePhoto(employeeID:int, writeToFile:File):void {
	//execute the query
	var st:Statement = con.createStatement();
	st.sql = "SELECT photo FROM employees WHERE employeeID = ?";
	st.setNumber(1, employeeID);
	
	var token:MySqlToken = st.executeQuery();
	token.employeeID = employeeID;
	token.writeToFile = writeToFile;
	token.addResponder(new AsyncResponder(
		function (data:Object, token:Object):void {
			var rs:ResultSet = ResultSet(data);
			if ( rs.next() ) {
				//get the outFile from the token
				var outFile:File = token.writeToFile;
				
				//get the file data from the result set
				var filedata:ByteArray = rs.getBinary("photo");
				
				//write the file
				var fs:FileStream = new FileStream();
				fs.open(outFile, FileMode.WRITE);
				fs.writeBytes(filedata);
				fs.close();
				
				Alert.show("Photo written to: " + outFile.nativePath);
			}
			else {
				Alert.show("Employee " + token.employeeID + " not found!");
			}
		},
		function (info:Object, token:Object):void {
			Alert.show("Error getting photo: " + info);
		},
		token
	));
}
```

### Stored Procedure Example ###

This is an example of calling a stored procedure that returns a ResultSet as well as output parameters.

```
import com.maclema.mysql.Statement;
import com.maclema.mysql.Connection;
import com.maclema.mysql.ResultSet;
import mx.controls.Alert;
import mx.rpc.AsyncResponder;
import com.maclema.mysql.MySqlToken;
import com.maclema.mysql.MySqlResponse;
import com.maclema.mysql.MySqlOutputParams;
import com.maclema.util.ResultsUtil;

//The MySql Connection
private var con:Connection;

private function onCreationComplete():void {
	con = new Connection("localhost", 3306, "root", "", "assql-test");
	con.addEventListener(Event.CONNECT, handleConnected);
	con.connect();
}

private function handleConnected(e:Event):void {
	var st:Statement = con.createStatement();
	st.sql = "CALL getEmployeeList(@LastUpdated)";
	st.registerOutputParameter("@LastUpdated");

	var token:MySqlToken = st.executeQuery();
	
	token.addResponder(new AsyncResponder(
		function(data:Object, token:Object):void {
			if ( data is ResultSet ) {
				//handle the results returned.
			}
			else if ( data is MySqlResponse ) {
				//check the affectedRows of the procedure
			}
			else if ( data is MySqlOutputParams ) {
				//get the output parameter.
				var lastUpdated:String = data.getParam("@LastUpdated");
			}
		},
		
		function(info:Object, token:Object):void {
			Alert.show("Error: " + info);
		},
		
		token
	));
}
```

### Streaming Results ###

This is an example of streaming a very large ResultSet and updating a DataGrid every time we receive 500 new rows.

```
<?xml version="1.0" encoding="utf-8"?>
<mx:WindowedApplication 
        xmlns:mx="http://www.adobe.com/2006/mxml" 
        xmlns:assql="com.maclema.mysql.mxml.*" 
        layout="absolute" 
        creationComplete="onCreationComplete()">
        
        <mx:Script>
        <![CDATA[
        	import mx.controls.Alert;
        	import mx.rpc.AsyncResponder;
        	import mx.collections.ArrayCollection;
        	import com.maclema.mysql.ResultSet;
        	import com.maclema.util.ResultsUtil;
        	import com.maclema.mysql.events.MySqlEvent;
        	import com.maclema.mysql.MySqlToken;
        	import com.maclema.mysql.Statement;
        	import com.maclema.mysql.Connection;
        	
        	private var con:Connection;
        	
			private function onCreationComplete():void {
				con = new Connection("localhost", 3306, "root", "", "assql-test");
				con.addEventListener(Event.CONNECT, handleConnected);
				con.connect();	
			}
			
			private function handleConnected(e:Event):void {
				var st:Statement = con.createStatement();
				
				//turn on results streaming
				st.streamResults = true;
				
				//dispatch new rows event every 500 new rows
				st.streamingInterval = 500;
				
				//execute a query
				var token:MySqlToken = st.executeQuery("SELECT * FROM employees");
				
				//listen for our result set columns
				token.addEventListener(MySqlEvent.COLUMNDATA, function(e:MySqlEvent):void {
					grid.columns = ResultsUtil.getDataGridColumns( e.resultSet );
					grid.dataProvider = new ArrayCollection();
				});
				
				//listen for new rows
				token.addEventListener(MySqlEvent.ROWDATA, function(e:MySqlEvent):void {
					addNewRows(e.resultSet);
				});				
				
				//add a responder
				token.addResponder(new AsyncResponder(
					function(data:Object, token:Object):void {
						//call add new rows again to ensure we have all the rows
						addNewRows(ResultSet(data));
					},
					function(info:Object, token:Object):void {
						Alert.show("Error: " + info);
					},
					token
				));
			}
			
			private function addNewRows(rs:ResultSet):void {
				//get our data provider
				var dp:ArrayCollection = grid.dataProvider as ArrayCollection;
				
				//get the collection of new rows
				var newRows:ArrayCollection = rs.getRows(false, dp.length, (rs.size()-dp.length));
				
				//concat our current source, and our new rows source
				dp.source = dp.source.concat( newRows.source );
				
				//refresh our data provider
				dp.refresh();
			}
		]]>
        </mx:Script>
        
        <mx:DataGrid id="grid" left="10" right="10" top="10" bottom="10" />
                
</mx:WindowedApplication>
```