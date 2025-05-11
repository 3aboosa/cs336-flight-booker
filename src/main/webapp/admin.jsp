<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>


<!DOCTYPE html>
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
			</select>
	
	<label for ="phone_number">Phone (for customers only):</label>
	<input type = "text" name = "phone">
	<button type = "submit" > Add User</button>

	</form>
	
	<hr style = "border: 1px solid #a6a6a6; margin: 20px 0;">
	
	
	<h2>Flight Reservations </h2>
	
	<form method = "get" action = "admin.jsp">
		<label for = "flight_id">Flight ID: </label>
		<input type = "text" name = "flight_id">
		<label for= "first_name">First Name:</label>
		<input type = "text" name="first_name" >
		<label for= "last_name">Last Name:</label>
		<input type = "text" name="last_name" >
	
		<input type="hidden" name="searchReservations" value="true">
		<button type = "submit" > Search</button>
	</form>
		<%
	    String reserve_flight_id = request.getParameter("flight_id");
	    String reserve_first_name = request.getParameter("first_name");
	    String reserve_last_name = request.getParameter("last_name");
	
	    boolean hasInput = (reserve_flight_id != null && !reserve_flight_id.trim().isEmpty()) || (reserve_first_name != null && !reserve_first_name.trim().isEmpty()) ||
	                       (reserve_last_name != null && !reserve_last_name.trim().isEmpty());

    	if (hasInput) {
		%>
		    <jsp:include page="reservations.jsp">
		        <jsp:param name="flight_id" value="<%= reserve_flight_id %>" />
		        <jsp:param name="first_name" value="<%= reserve_first_name %>" />
		        <jsp:param name="last_name" value="<%= reserve_last_name %>" />
		    </jsp:include>
		<%
		    }
		%>
		<hr style = "border: 1px solid #a6a6a6; margin: 20px 0;">
		
		
		<h2>Sales Report</h2>
	
		<form method="post" action="admin.jsp">
		    <label for="sales_month">Select Month:</label>
		    <input type= "month" name="sales_month" required >
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
		<label for = "revenue_flight_id">Flight ID: </label>
		<input type = "text" name = "revenue_flight_id">
		<label for = "revenue_airline_id">Airline ID: </label>
		<input type = "text" name = "revenue_airline_id">
		<label for= "revenue_first_name">First Name:</label>
		<input type = "text" name="revenue_first_name" >
		<label for= "revenue_last_name">Last Name:</label>
		<input type = "text" name="revenue_last_name" >
		<button type = "submit" > Generate Summary</button>
	</form>
		<%
	    String revenue_flight_id = request.getParameter("revenue_flight_id");
		String revenue_airline_id = request.getParameter("revenue_airline_id");
	    String revenue_first_name = request.getParameter("revenue_first_name");
	    String revenue_last_name = request.getParameter("revenue_last_name");
	
	    boolean hasInput2 = (revenue_flight_id != null && !revenue_flight_id.trim().isEmpty()) || (revenue_first_name != null && !revenue_first_name.trim().isEmpty()) 
	    					|| (revenue_last_name != null && !revenue_last_name.trim().isEmpty()) || (revenue_airline_id != null && !revenue_airline_id.trim().isEmpty());

    	if (hasInput2) {
		%>
		    <jsp:include page="revenue.jsp">
		        <jsp:param name="revenue_flight_id" value="<%= revenue_flight_id %>" />
		        <jsp:param name="airline_id2" value="<%= revenue_airline_id %>" />
		        <jsp:param name="first_name2" value="<%= revenue_first_name %>" />
		        <jsp:param name="last_name2" value="<%= revenue_last_name %>" />
		    </jsp:include>
		<%
		    }
		%>
		<h3 style="text-decoration: underline; font-weight:bold">Customer with Most Revenue</h3>

		
			<form method="get" action="admin.jsp">
		    <label for="topCount">Top #:</label>
		    <input type="number" name="topCount" id="topCount" min="1" required>
		    
		    <div style="margin-top: 10px; margin-bottom: 10px;">
		        <label for="startDate">Start Date:</label>
		        <input type="date" name="startDate" id="startDate">
		        
		        <label for="endDate">End Date:</label>
		        <input type="date" name="endDate" id="endDate">
		    
		        <div class="button-container" style="margin-top: 10px;">
		            <button type="submit" name="generateType" value="dateRange">Generate by Date Range</button>
		            <button type="submit" name="generateType" value="allTime">Generate All-Time Top Customers</button>
		        </div>
		    </div>
		    
		    <input type="hidden" name="mostRevenueCustomer" value="true">
		</form>
		
		<%
		    String mostRevenue = request.getParameter("mostRevenueCustomer");
		    String generateType = request.getParameter("generateType");
		    if (mostRevenue != null && mostRevenue.equals("true")) {
		%>
		    <jsp:include page="mostRevenueCustomer.jsp" />
		<%
		    }
		%>
		<h3 style="text-decoration: underline; font-weight:bold">Most Active Flights (All-Time)</h3>

		
			<form method="get" action="admin.jsp">
		    <label for="topFlightCount">Top #:</label>
		    <input type="number" name="topFlightCount" id="topFlightCount" min="1" required>
		    
		    <div style="margin-top: 10px; margin-bottom: 10px;">
		        <label for="flightStartDate">Start Date:</label>
		        <input type="date" name="flightStartDate" id="flightStartDate">
		        
		        <label for="flightEndDate">End Date:</label>
		        <input type="date" name="flightEndDate" id="flightEndDate">
		    
		        <div class="button-container" style="margin-top: 10px;">
		            <button type="submit" name="flightGenerateType" value="flightDateRange">Generate by Date Range</button>
		            <button type="submit" name="flightGenerateType" value="flightAllTime">Generate All-Time Top Flights</button>
		        </div>
		    </div>
		    
		    <input type="hidden" name="mostActiveFlight" value="true">
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
