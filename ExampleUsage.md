Sample usage of the asSQL MySql driver.
```
//The database connection object
private var con:Connection;

//Sample of connecting to a database
private function onCreationComplete():void {
	con = new Connection("localhost", 3306, "root", "password", "database name");
	con.addEventListener(Event.CONNECT, handleConnect);
	con.addEventListener(MySqlErrorEvent.SQL_ERROR, handleConnectionError);
	con.connect();
}

private function handleConnect(e:Event):void {	
	//woop! were connected, do something here
}

private function handleConnectionError(e:MySqlErrorEvent):void {
	Alert.show("Connection Error: " + e.text, "Error");
}

// This is a sample query using a statement and responders
private function sampleQuery1():void {
	var st:Statement = con.createStatement();
	st.executeQuery("SELECT * FROM users", new MySqlResponser(
		function (e:MySqlEvent):void {
			Alert.show("Returned: " + e.resultSet.size() + " rows!");
		},
		
		function (e:MySqlErrorEvent):void {
			Alert.show("Error: " + e.text);
		}
	));
}

//This is a sample query using a statement, responders, and parameters
private function sampleQuery2():void {
	var st:Statement = con.createStatement();
	st.sql = "SELECT * FROM users WHERE userID = ?";
	st.setNumber(1, 5);
	st.executeQuery(null, new MySqlResponser(
		function (e:MySqlEvent):void {
			Alert.show("Returned: " + e.resultSet.size() + " rows!");
		},
		
		function (e:MySqlErrorEvent):void {
			Alert.show("Error: " + e.text);
		}
	)); 
}

//This is a sample query using a statement and event listeners
private function sampleQuery3():void {
	var st:Statement = con.createStatement();
	st.addEventListener(MySqlEvent.RESULT, handleResult);
	st.executeQuery("SELECT * FROM users");
}

//This is a sample result handler that creates a datagrid to
//display the results returned by the query
private function handleResult(e:MySqlEvent):void {
	var rs:ResultSet = e.resultSet;
	
	myDataGrid.columns = ResultsUtil.getDataGridColumns( rs );
	myDataGrid.dataProvider = rs.getRows();
}
```

MySqlServiceExample

```
<?xml version="1.0" encoding="utf-8"?>
<mx:WindowedApplication xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute" xmlns:assql="com.maclema.mysql.*">
	<mx:Script>
		<![CDATA[
			import com.maclema.util.ResultsUtil;
			
			private function handleConnected(e:Event):void {
				sqlService.send("SELECT * FROM users");
			}
		]]>
	</mx:Script>
	
	<assql:MySqlService 
			id="sqlService" 
			hostname="localhost" 
			username="root" 
			password="" 
			database="assql-test" 
			autoConnect="true"
			connect="handleConnected(event)" />
	
	<mx:DataGrid id="grid" left="10" right="10" top="10" bottom="10"
		dataProvider="{sqlService.lastResult}" 
		columns="{ResultsUtil.getDataGridColumns(sqlService.lastResultSet)}">
	</mx:DataGrid>
	
</mx:WindowedApplication>

```