
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