Here are some sample queries to give an idea of the performance. All queries were ran connecting to a local mysql server.

**Updated: July 27 2008. Tests ran against [revision 130](https://code.google.com/p/assql/source/detail?r=130)**

I ran all these queries on a MacBook Pro, 2.4GHz Core 2, 4GB Ram, 7200rpm Drive.

All queries ran against the following table selecting all columns.
```
CREATE TABLE `employees` (
  `employeeID` int(11) NOT NULL auto_increment,
  `username` varchar(255) character set latin1 default NULL,
  `enabled` tinyint(1) default NULL,
  `hourlyWage` decimal(8,2) default NULL,
  `startDate` date default NULL,
  `shiftStartTime` time default NULL,
  `photo` longblob,
  `createDate` datetime default NULL,
  `modifyDate` timestamp NOT NULL default '0000-00-00 00:00:00' on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`employeeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```
```
[DEBUG] com.maclema.mysql::QueryHandler            : Mysql Result
[DEBUG] com.maclema.mysql::QueryHandler            :   Rows:       10
[DEBUG] com.maclema.mysql::QueryHandler            :   Query Size: 1.48 KB
[DEBUG] com.maclema.mysql::QueryHandler            :   Total TX:   1.57 KB
[DEBUG] com.maclema.mysql::QueryHandler            :   Query Time: 19 ms

[DEBUG] com.maclema.mysql::QueryHandler            : Mysql Result
[DEBUG] com.maclema.mysql::QueryHandler            :   Rows:       100
[DEBUG] com.maclema.mysql::QueryHandler            :   Query Size: 9.11 KB
[DEBUG] com.maclema.mysql::QueryHandler            :   Total TX:   10.68 KB
[DEBUG] com.maclema.mysql::QueryHandler            :   Query Time: 16 ms

[DEBUG] com.maclema.mysql::QueryHandler            : Mysql Result
[DEBUG] com.maclema.mysql::QueryHandler            :   Rows:       1000
[DEBUG] com.maclema.mysql::QueryHandler            :   Query Size: 87.06 KB
[DEBUG] com.maclema.mysql::QueryHandler            :   Total TX:   97.75 KB
[DEBUG] com.maclema.mysql::QueryHandler            :   Query Time: 87 ms

[DEBUG] com.maclema.mysql::QueryHandler            : Mysql Result
[DEBUG] com.maclema.mysql::QueryHandler            :   Rows:       10000
[DEBUG] com.maclema.mysql::QueryHandler            :   Query Size: 878.22 KB
[DEBUG] com.maclema.mysql::QueryHandler            :   Total TX:   975.98 KB
[DEBUG] com.maclema.mysql::QueryHandler            :   Query Time: 346 ms

[DEBUG] com.maclema.mysql::QueryHandler            : Mysql Result
[DEBUG] com.maclema.mysql::QueryHandler            :   Rows:       100000
[DEBUG] com.maclema.mysql::QueryHandler            :   Query Size: 8,878.23 KB
[DEBUG] com.maclema.mysql::QueryHandler            :   Total TX:   9,854.22 KB
[DEBUG] com.maclema.mysql::QueryHandler            :   Query Time: 3526 ms

[DEBUG] com.maclema.mysql::QueryHandler            : Mysql Result
[DEBUG] com.maclema.mysql::QueryHandler            :   Rows:       200000
[DEBUG] com.maclema.mysql::QueryHandler            :   Query Size: 17,864.99 KB
[DEBUG] com.maclema.mysql::QueryHandler            :   Total TX:   27,719.21 KB
[DEBUG] com.maclema.mysql::QueryHandler            :   Query Time: 7340 ms
```