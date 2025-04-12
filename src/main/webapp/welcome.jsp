<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Welcome</title>
	</head>
	
	<body style="margin: 0; padding: 0; box-sizing: border-box; font-family: Arial, sans-serif;">
		<%
		
		  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
		  response.setHeader("Pragma", "no-cache");
		  response.setDateHeader("Expires", 0);
		  
		  if (session.getAttribute("username") == null) {
		    response.sendRedirect("login.jsp");
		    return;
		  }
		
		  String username = (String) session.getAttribute("username");
		  String firstName = "";
		
		  try {
			  ApplicationDB db = new ApplicationDB();	
				Connection con = db.getConnection();
		
		    PreparedStatement stmt = con.prepareStatement("SELECT fname FROM individual WHERE username = ?");
		    stmt.setString(1, username);
		    ResultSet rs = stmt.executeQuery();
		
		    if (rs.next()) {
		      firstName = rs.getString("fname");
		    }
		
		    rs.close();
		    stmt.close();
		    con.close();
		  } catch (Exception e) {
		    out.println("Error: " + e.getMessage());
		  }
		%>
		
		<div>
	    	<a href="handleLogout.jsp">Logout</a>
	  	</div>
	
	  	<h1>Welcome, <%= firstName %>!</h1>
		
</body>
</html>