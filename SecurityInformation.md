# Some basic security information.

As of Flash Player 9.0.124.0, Sockets are not allowed to make requests to ports on the same, or other domains, unless the domain you are connecting to is serving a socket policy file. Prior to 9.0.124.0, a crossdomain.xml file would work just fine. Now, however, you need to setup a server socket on port 843, that listens for socket connections from flash, and serves a socket policy file.

Here is the absolute simplest configuration for the socket policy file:

```
<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM "/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
   <allow-access-from domain="*" to-ports="3306" />
</cross-domain-policy>
```

The policy file needs to be served from a socket, listening on port 843 (TCP). Flash will send the request "

&lt;policy-file-request/&gt;

\0", when the server receives this string, it should return the policy file, followed by a null byte.


---


Java Policy File Server:

See JavaPolicyFileServer wiki entry.


---


PHP Flash Policy Daemon:

http://ammonlauritzen.com/blog/2008/04/22/flash-policy-service-daemon/


---


C# Flash Policy Server:

http://giantflyingsaucer.com/blog/?p=15


---


VB.NET Flash Policy Server:

http://www.gamedev.net/community/forums/topic.asp?topic_id=455949


---


Python / Perl Flash Policy Servers:

http://www.adobe.com/devnet/flashplayer/articles/socket_policy_files.html


---


More Information:

http://www.adobe.com/devnet/flashplayer/articles/fplayer9_security_04.html