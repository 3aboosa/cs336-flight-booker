<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Login</title>
	</head>
	
	<body>
		<%
		  String fname = request.getParameter("fname");
		  String lname = request.getParameter("lname");
		  String username = request.getParameter("username");
		  String password = request.getParameter("passwd");
		  String confirm = request.getParameter("confirmpasswd");
		
		  if (fname == null || lname == null || username == null || password == null || confirm == null) {
		    response.sendRedirect("signup.jsp?error=Missing+form+fields");
		    return;
		  }
		
		  if (!password.equals(confirm)) {
		    response.sendRedirect("signup.jsp?error=Passwords+do+not+match");
		    return;
		  }
		
		  try {
			ApplicationDB db = new ApplicationDB();	
			Connection con = db.getConnection();
		
		    PreparedStatement check = con.prepareStatement("SELECT * FROM individual WHERE username = ?");
		    check.setString(1, username);
		    ResultSet rs = check.executeQuery();
		
		    if (rs.next()) {
		      response.sendRedirect("signup.jsp?error=Username+already+exists");
		    } else {
		      PreparedStatement insert = con.prepareStatement("INSERT INTO individual (fname, lname, username, password) VALUES (?, ?, ?, ?)");
		      insert.setString(1, fname);
		      insert.setString(2, lname);
		      insert.setString(3, username);
		      insert.setString(4, password);
		      insert.executeUpdate();
		
		      response.sendRedirect("welcome.jsp?success=1");
		    }
		
		    rs.close();
		    check.close();
		    con.close();
		
		  } catch (Exception e) {
		    response.sendRedirect("signup.jsp?error=Database+error");
		  }
		%>
		
	</body>
</html>