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
	
	<body style="margin: 20px; padding: 0; box-sizing: border-box; font-family: Arial, sans-serif;">
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
		
		    PreparedStatement stmt = con.prepareStatement("SELECT first_name FROM individual WHERE username = ?");
		    stmt.setString(1, username);
		    ResultSet rs = stmt.executeQuery();
		
		    if (rs.next()) {
		      firstName = rs.getString("first_name");
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
	  	<%
			  String error = request.getParameter("error");
			  if (error != null && !error.trim().isEmpty()) {
			%>
			  <p style="color: red;"><%= error %></p>
			<%
			  }
			%>
	
	  	<h1>Welcome, Admin <%= firstName %>!</h1>
		
		
		<style>
		table {
		  font-family: arial, sans-serif;
		  border-collapse: collapse;
		  width: 100%;
		}
		
		td, th {
		  border: 1px solid #dddddd;
		  text-align: left;
		  padding: 8px;
		}

		tr:nth-child(even) {
		  background-color: #dddddd;
		}
		</style>
	
	<hr style = "border: 1px solid #a6a6a6; margin: 20px 0;">
		<h2>Manage Users </h2>
	
		<form method="get">
		<label for="manageSearch">Search by: Username or Name:</label>
		<input type="text" name="manageSearch" id="manageSearch" >
		<button type="submit">Search</button>
		</form>
	<%
	    String manageSearch = request.getParameter("manageSearch");
	    if (manageSearch != null && !manageSearch.trim().isEmpty()) {
	%>
	    <jsp:include page="manageUsers.jsp">
	        <jsp:param name="manageSearch" value="<%= manageSearch %>" />
	    </jsp:include>
	<%
	    }
	%>

		
		<h3 style="text-decoration: underline; font-weight:bold">Add User</h3>
	<form method = "post" action = "addUser.jsp">
		<label for= "add_username">Username:</label>
		<input type = "text" name="add_username" required>
		
		<label for= "add_password">Password:</label>
		<input type = "text" name="add_password" required>
		
		<label for= "add_first_name">First Name:</label>
		<input type = "text" name="add_first_name" required >
		
		<label for= "add_last_name">Last Name:</label>
		<input type = "text" name= "add_last_name" required>
		<label for="role">Role: </label>
			<select name = "role" >
				<option value = "customer">Customer </option>
				<option value = "customerrepresentative">Customer Representative </option>
				<option value = "admin">Administrator </option>
			</select>
	
	<label for ="phone_number">Phone (for customers only):</label>
	<input type = "text" name = "phone">
	<button type = "submit" > Add User</button>
	</form>
		<hr style = "border: 1px solid #a6a6a6; margin: 20px 0;">
	
		<h2>Flight Reservations </h2>
	
		<form method = "post" action = "admin.jsp">
			<label for = "flight_id">Flight ID: </label>
			<input type = "text" name = "flight_id">
			<label for= "first_name">First Name:</label>
			<input type = "text" name="first_name" >
			<label for= "last_name">Last Name:</label>
			<input type = "text" name="last_name" >
		
		<button type = "submit" > Search</button>
		<%
	    String flightId = request.getParameter("flight_id");
	    String first_name = request.getParameter("first_name");
	    String last_name = request.getParameter("last_name");
	
	    boolean hasInput = (flightId != null && !flightId.trim().isEmpty()) ||
	                       (first_name != null && !first_name.trim().isEmpty()) ||
	                       (last_name != null && !last_name.trim().isEmpty());

    	if (hasInput) {
		%>
		    <jsp:include page="reservations.jsp">
		        <jsp:param name="flight_id" value="<%= flightId %>" />
		        <jsp:param name="first_name" value="<%= first_name %>" />
		        <jsp:param name="last_name" value="<%= last_name %>" />
		    </jsp:include>
		<%
		    }
		%>
		<hr style = "border: 1px solid #a6a6a6; margin: 20px 0;">
		
	
		
		<h2>Sales Report</h2>
	
		<form method="post" action="admin.jsp">
	    <label for="sales_month">Select Month:</label>
	    <input type="month" name="sales_month" >
	    <button type="submit">Generate Report</button>
		</form>
		<%
	    String salesMonth = request.getParameter("sales_month");
	    if (salesMonth != null && !salesMonth.trim().isEmpty()) {
		%>
		    <jsp:include page="salesReport.jsp">
		        <jsp:param name="sales_month" value="<%= salesMonth %>" />
		    </jsp:include>
		<%
		    }
		%>
				
	<hr style = "border: 1px solid #a6a6a6; margin: 20px 0;">
		
	<h2>Revenue</h2>
	<form method = "post" action = "admin.jsp">
		<label for = "flight_id2">Flight ID: </label>
		<input type = "text" name = "flight_id2">
		<label for = "airline_id2">Airline ID: </label>
		<input type = "text" name = "airline_id2">
		<label for= "first_name2">First Name:</label>
		<input type = "text" name="first_name2" >
		<label for= "last_name2">Last Name:</label>
		<input type = "text" name="last_name2" >
		
		<button type = "submit" > Generate Summary</button>
		<%
	    String flightId2 = request.getParameter("flight_id2");
		String airlineId2 = request.getParameter("airline_id2");
	    String first_name2 = request.getParameter("first_name2");
	    String last_name2 = request.getParameter("last_name2");
	
	    boolean hasInput2 = (flightId2 != null && !flightId2.trim().isEmpty()) ||
	                       (first_name2 != null && !first_name2.trim().isEmpty()) ||
	                       (last_name2 != null && !last_name2.trim().isEmpty()) ||
	                       (airlineId2 != null && !airlineId2.trim().isEmpty());

    	if (hasInput2) {
		%>
		    <jsp:include page="revenue.jsp">
		        <jsp:param name="flight_id2" value="<%= flightId2 %>" />
		        <jsp:param name="airline_id2" value="<%= airlineId2 %>" />
		        <jsp:param name="first_name2" value="<%= first_name2 %>" />
		        <jsp:param name="last_name2" value="<%= last_name2 %>" />
		    </jsp:include>
		<%
		    }
		%>
		<h3 style="text-decoration: underline; font-weight:bold">Customer with Most Revenue (All-Time)</h3>

		<form method="get" action="admin.jsp">
			
		    <input type="hidden" name="mostRevenueCustomer" value="true">
		    <button type="submit">Generate Top Customer</button>
		</form>
		
		<%
		    String mostRevenue = request.getParameter("mostRevenueCustomer");
		    if (mostRevenue != null && mostRevenue.equals("true")) {
		%>
		    <jsp:include page="mostRevenueCustomer.jsp" />
		<%
		    }
		%>
		<h3 style="text-decoration: underline; font-weight:bold">Most Active Flights (All-Time)</h3>

		<form method="get" action="admin.jsp">
			
		    <input type="hidden" name="mostActiveFlight" value="true">
		    <button type="submit">Generate Most Active Flights</button>
		</form>
		
		<%
		    String mostActiveFlight = request.getParameter("mostActiveFlight");
		    if (mostActiveFlight != null && mostActiveFlight.equals("true")) {
		%>
		    <jsp:include page="mostActiveFlight.jsp" />
		<%
		    }
		%>
		
</html>	
