# Sample Java Flash Policy File Server.

This is a simple Java servlet, that opens a server socket on port 843 when the web application is started. It listens for "

&lt;policy-file-request/&gt;

\0" requests, and writes the policy file to the connected client.

The policy file is read from "/tomcat/policyserver/ROOT/flashpolicy.xml", this can be changed in the servlet code.

Here is what you will need in web.xml:

```
<servlet>
	<servlet-name>PolicyServerServlet</servlet-name>
	<servlet-class>com.maclema.flash.PolicyServerServlet</servlet-class>
	<load-on-startup>1</load-on-startup>
</servlet>

<servlet-mapping>
	<servlet-name>PolicyServerServlet</servlet-name>
	<url-pattern>/policyserver</url-pattern>
</servlet-mapping>
```

and here is the servlet code:

```
package com.maclema.flash;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;

import javax.servlet.http.HttpServlet;

public class PolicyServerServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	private static ServerSocket serverSock;
	private static boolean listening = true;
	private static Thread serverThread;
	
	static {
		try {
			serverThread = new Thread(new Runnable(){
				public void run() {
					try {
						System.out.println("PolicyServerServlet: Starting...");
						serverSock = new ServerSocket(843, 50);
						
						while ( listening ) {
							System.out.println("PolicyServerServlet: Listening...");
							final Socket sock = serverSock.accept();
							
							Thread t = new Thread(new Runnable() {
								public void run() {
									try {
										System.out.println("PolicyServerServlet: Handling Request...");
										
										sock.setSoTimeout(10000);
										
										InputStream in = sock.getInputStream();
										
										byte[] buffer = new byte[23];
										
										if ( in.read(buffer) != -1 && (new String(buffer)).startsWith("<policy-file-request/>") ) {
											System.out.println("PolicyServerServlet: Serving Policy File...");
											
											//get the local tomcat path, and the path to our flashpolicy.xml file
											File policyFile = new File("/tomcat/policyserver/ROOT/flashpolicy.xml");
											
											BufferedReader fin = new BufferedReader(new FileReader(policyFile));
											
											OutputStream out = sock.getOutputStream();
											
											String line;
											while ( (line=fin.readLine()) != null ) {
												out.write(line.getBytes());
											}
											
											fin.close();
											
											out.write(0x00);
											
											out.flush();
											out.close();
										}
										else {
											System.out.println("PolicyServerServlet: Ignoring Invalid Request");
											System.out.println("  " + (new String(buffer)));
										}
										
									}
									catch ( Exception ex ) {
										System.out.println("PolicyServerServlet: Error: " + ex.toString());
									}
									finally {
										try { sock.close(); } catch ( Exception ex2 ) {}
									}
								}
							});
							t.start();
						}
					}
					catch ( Exception ex ) {
						System.out.println("PolicyServerServlet: Error: " + ex.toString());
					}
				}
			});
			serverThread.start();
			
		}
		catch ( Exception ex ) {
			System.out.println("PolicyServerServlet Error---");
			ex.printStackTrace(System.out);
		}
	}
	
	public void destroy() {
		System.out.println("PolicyServerServlet: Shutting Down...");
		
		if ( listening ) {
			listening = false;
		}
		
		if ( !serverSock.isClosed() ) {
			try { serverSock.close(); } catch ( Exception ex ) {}
		}
	}
}
```

and this is my flashpolicy.xml:

```
<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM "/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
   <allow-access-from domain="*" to-ports="3306" />
</cross-domain-policy>
```