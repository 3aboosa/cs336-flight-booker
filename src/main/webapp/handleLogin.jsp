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
		  String role = "Customer"; // default 
		  String firstName = "";
		  int uid = -1; // initial
		
		  try {
			ApplicationDB db = new ApplicationDB();	
			Connection con = db.getConnection();
			// changed below to select uid as well 
		    PreparedStatement stmt = con.prepareStatement("SELECT first_name, password, uid FROM individual WHERE username = ?");
		    stmt.setString(1, username);
		    ResultSet rs = stmt.executeQuery();
		
		    if (rs.next()) {
		      String dbPassword = rs.getString("password");
		      if (dbPassword.equals(password)) {
		        validUser = true;
		        firstName = rs.getString("first_name");
		        uid = rs.getInt("uid");
		        
		        PreparedStatement stmt2 = con.prepareStatement("SELECT * FROM admin WHERE uid =?");
		        stmt2.setInt(1, uid);
		        ResultSet adminrs = stmt2.executeQuery();
		        if (adminrs.next()){
		        	role = "admin";
		        }
		        adminrs.close();
		        stmt2.close();
		        
		        if (role.equals("admin")== false){
		        	PreparedStatement stmt3 = con.prepareStatement("SELECT * FROM customerrepresentative WHERE uid= ?");
		        	stmt3.setInt(1,uid);
		        	ResultSet reprs = stmt3.executeQuery();
		        	if (reprs.next()){
		        		role = "customerrepresentative";
		     
		        	}
		        	reprs.close();
		        	stmt3.close();
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
		   	session.setAttribute("uid", uid); // added
		   	// added the try below here
		   	
			if(role.equals("admin")){
				response.sendRedirect("admin.jsp");
			} else if (role.equals("customerrepresentative")){
				response.sendRedirect("customerrepresentative.jsp");
			} else {
		    	response.sendRedirect("welcome.jsp"); // default, that they are a customer 
			}
		  } else {
		    response.sendRedirect("login.jsp?error=Invalid+username+or+password");
		  }
		%>
		
		
	</body>
</html>