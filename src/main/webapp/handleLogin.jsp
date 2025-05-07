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
		  String username = request.getParameter("username");
		  String password = request.getParameter("passwd");
		
		  if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
		    response.sendRedirect("login.jsp?error=Missing+username+or+password");
		    return;
		  }
		
		  boolean validUser = false;
		  String firstName = "";
		  boolean customerREP = false;
		
		  try {
			ApplicationDB db = new ApplicationDB();	
			Connection con = db.getConnection();
		
		    PreparedStatement stmt = con.prepareStatement("SELECT first_name, password, uid FROM individual WHERE username = ?");
		    PreparedStatement stmt2 = con.prepareStatement("SELECT * from customerrepresentative where uid = ?");
		    stmt.setString(1, username);
		    ResultSet rs = stmt.executeQuery();
		
		    if (rs.next()) {
		      String dbPassword = rs.getString("password");
		      if (dbPassword.equals(password)) {
		        validUser = true;
		        firstName = rs.getString("first_name");
		        int uid = rs.getInt("uid");
		        stmt2.setInt(1, uid);
		        ResultSet rs2 = stmt2.executeQuery();
		        if (rs2.next()){
		        	customerREP = true;
		        }
		      }
		    }
		
		    rs.close();
		    stmt.close();
		    con.close();
		  } catch (Exception e) {
		    response.sendRedirect("login.jsp?error=Database+error");
		    return;
		  }
		
		  if (validUser) {
		    session.setAttribute("username", username);
		    session.setAttribute("firstName", firstName);
			if (customerREP){
				response.sendRedirect("Customerrep.jsp");
			} else{
				response.sendRedirect("welcome.jsp");
			}
		  } else {
		    response.sendRedirect("login.jsp?error=Invalid+username+or+password");
		  }
		%>
		
		
	</body>
</html>