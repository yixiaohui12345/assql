asSQL is an Actionscript 3 Mysql Driver aimed towards AIR projects to allow Mysql database connectivity directly from Actionscript.

### Subscribe For Updates ###
If you wish to receive update notifications without all the other group emails, you can subscribe to the [asSQL-Updates Group](http://groups.google.com/group/assql-updates). You will ONLY receive emails from this group when there are new updates released.


---


### Server Bolt Supports asSQL ###

Finally, a hosting company that supports Flash Policy File servers. More information here: http://www.serverbolt.com/services/custom-hosting


---


### March 1 2010 ([Beta 2.8](http://assql.googlecode.com/files/asSQL-Beta2.8.swc)) ###

Sorry all. I know it's been forever and a day since an update. But here is a small one that fixes a concurrency issue with stored procedure calls. It may also fix an issue that causes the incorrect ResultSet to be returned when calling stored procedures.

Issues Resolved: [Issue #59](https://code.google.com/p/assql/issues/detail?id=#59), [Issue #84](https://code.google.com/p/assql/issues/detail?id=#84)

---


### August 8 2008 ([Beta 2.7](http://assql.googlecode.com/files/asSQL-Beta2.7.swc)) ###

Lots of performance and memory issues resolved in this release. Also added support for streaming results, stored procedure output parameters.

Check out the [Stored Procedure Example](Examples#Stored_Procedure_Example.md) and [Streaming Results Example](Examples#Streaming_Results.md)

This will probably be the last beta release before the first stable release. The next release will most likely not contain any new features. So please post any bugs you find so I can get them fixed.

Issues Resolved in this release: [Issue #53](https://code.google.com/p/assql/issues/detail?id=#53), [Issue #54](https://code.google.com/p/assql/issues/detail?id=#54), [Issue #55](https://code.google.com/p/assql/issues/detail?id=#55), [Issue #56](https://code.google.com/p/assql/issues/detail?id=#56), [Issue #57](https://code.google.com/p/assql/issues/detail?id=#57), [Issue #58](https://code.google.com/p/assql/issues/detail?id=#58)


---


### June 14 2008 ([Beta 2.6](http://assql.googlecode.com/files/asSQL-Beta2.6.swc)) ###

This release contains a few changes, including the first stage of support for internationalization. You can now specify a mysql character set to use when calling the connect() method of the Connection class, or by specifying the charSet property of the MySqlService class.

Issues Resolved in this release: [Issue #36](https://code.google.com/p/assql/issues/detail?id=#36), [Issue #43](https://code.google.com/p/assql/issues/detail?id=#43), [Issue #44](https://code.google.com/p/assql/issues/detail?id=#44), [Issue #45](https://code.google.com/p/assql/issues/detail?id=#45), [Issue #46](https://code.google.com/p/assql/issues/detail?id=#46)


---


### June 9 2008 ([Beta 2.5.1](http://assql.googlecode.com/files/asSQL-Beta2.5.1.swc)) ###

Resolved a high priority issue when reading packets that was causing an EOF error. ([Issue #42](https://code.google.com/p/assql/issues/detail?id=#42))


---


### June 8 2008 ([Beta 2.5](http://assql.googlecode.com/files/asSQL-Beta2.5.swc)) ###

Beta 2.5! This release contains A LOT of changes and will most likely **not be reverse compatible** with existing code. There are a lot of core changes, including the ability to use tokens / responders similar to HTTPService and RemoteObject. Please see the new [Exmaples](http://code.google.com/p/assql/wiki/Examples) wiki page for detailed examples.

As there are a lot of requests for this, there are also examples on [Inserting](http://code.google.com/p/assql/wiki/Examples#Inserting_Binary_Data_Example) and [Selecting](http://code.google.com/p/assql/wiki/Examples#Selecting_Binary_Data_Example) binary data!

Issues Resolved in this release: [Issue #22](https://code.google.com/p/assql/issues/detail?id=#22), [Issue #24](https://code.google.com/p/assql/issues/detail?id=#24), [Issue #25](https://code.google.com/p/assql/issues/detail?id=#25), [Issue #27](https://code.google.com/p/assql/issues/detail?id=#27), [Issue #28](https://code.google.com/p/assql/issues/detail?id=#28), [Issue #29](https://code.google.com/p/assql/issues/detail?id=#29), [Issue #31](https://code.google.com/p/assql/issues/detail?id=#31), [Issue #32](https://code.google.com/p/assql/issues/detail?id=#32), [Issue #33](https://code.google.com/p/assql/issues/detail?id=#33), [Issue #37](https://code.google.com/p/assql/issues/detail?id=#37), [Issue #38](https://code.google.com/p/assql/issues/detail?id=#38), [Issue #39](https://code.google.com/p/assql/issues/detail?id=#39)