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
	
	<body style="margin: 0; padding: 0; box-sizing: border-box; font-family: Arial, sans-serif;">
	
		<div style="display: flex; justify-content: flex-start; margin: 10px; font-weight: bold;">
			<a href="HelloWorld.jsp">DAV AIR</a>
		</div>
		<div style="display: flex; flex-direction: column; justify-content: center; align-items: center; margin: 10px;">
		
			<div style="font-size: 18px; margin-bottom: 10px;">
				LOG IN
			</div>
			<%
			  String error = request.getParameter("error");
			  if (error != null && !error.trim().isEmpty()) {
			%>
			  <p style="color: red;"><%= error %></p>
			<%
			  }
			%>
			<div style="display: flex; flex-direction: column; align-items: center; justify-content: space-evenly; height: 100%; border: 1px solid gray; padding: 0 6px 10px 6px;" >
				<form method="post" action="handleLogin.jsp">
					<p style="margin: 8px; padding: 0; margin: 6px 0 6px 0;">Username:</p>
					<input name="username" style="display: inline-block;" type="text" placeholder="Username" />

					<p style="margin: 8px; padding: 0; margin: 6px 0 6px 0;">Password:</p>
					<input name="passwd" style="display: inline-block;" type="password" placeholder="Password" />
					<input type="submit" value="Log In" style="margin-top: 8px;" />
				</form>
			</div>
		</div>
	</body>
</html>