<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Sign Up</title>
	</head>
	
	<body style="margin: 0; padding: 0; box-sizing: border-box; font-family: Arial, sans-serif;">
	
		<div style="display: flex; justify-content: flex-start; margin: 10px; font-weight: bold;">
			<a href="HelloWorld.jsp">DAV AIR</a>
		</div>
		<div style="display: flex; flex-direction: column; justify-content: center; align-items: center; margin: 10px;">
		
			<div style="font-size: 18px; margin-bottom: 10px;">
				CREATE ACCOUNT
			</div>
			<%
			  String error = request.getParameter("error");
			  if (error != null && !error.trim().isEmpty()) {
			%>
			  <p style="color:red;"><%= error %></p>
			<%
			  }
			%>
			
			<div style="display: flex; flex-direction: column; align-items: center; justify-content: space-evenly; text-align: center; height: 100%; border: 1px solid gray; padding: 0 6px 10px 6px;" >
				<form method="post" action="handleCreateAccount.jsp" style="align-items: center;">
					<p style="margin: 8px; padding: 0;">Enter full name:</p>
					<input name="fname" type="text" placeholder="First name" />
					<input name="lname" type="text" placeholder="Last name" />
					
					<p style="margin: 8px; padding: 0;">Enter a username:</p>
					<input name="username"style="display: inline-block;" type="text" placeholder="Username" />
					

					<p style="margin: 8px; padding: 0;">Enter a strong password:</p>
					<input name="passwd"style="display: inline-block;" type="password" placeholder="Password" />
				
					<p style="margin: 8px; padding: 0;">Confirm strong password:</p>
					<input name="confirmpasswd"style="display: inline-block;" type="password" placeholder="Re-enter password" />
				
					<input type="submit" value="Create Account" style="display: inline; margin-top: 8px;" />
				</form>
			</div>
			<div style="display: flex; flex-direction: column; justify-content: space-between; align-items: center; text-align: center;">
				<p style="margin: 8px;">Already have an account?</p>
				<a href="login.jsp">Login here</a>
			</div>
		</div>
		
</body>
</html>