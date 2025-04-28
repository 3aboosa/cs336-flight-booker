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
	
	  	<h1>Welcome, <%= firstName %>!</h1>
	  	<form method ="get">
		  <label for="Source"> From:</label> <input type="text" id="Source" name="Source">
		  <label for="Destination">To:</label> <input type="text" id="Destination" name="Destination">
		  
		    <label for="departure">Departure:</label>
		    <input type="date" id="departure" name="departure" required>
		
		    <label for="arrival">Arrival:</label>
		    <input type="date" id="arrival" name="arrival" required>
		    <input type="checkbox" id="FlexibleDates" name="FlexibleDates">
  			<label for="FlexibleDates"> Flexible Dates (+/- 3 Days)</label>
		
		    <button type="submit">Search</button>
		  </form>
		<body>
		
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
		<body>

		<h2>Available Flights</h2>

		<table>
		  <tr>
		    <th>Flight ID</th>
		    <th>Departure Time</th>
		    <th>Departure Location</th>
		    <th>Arrival Time </th>
		    <th>Arrival Location </th>
		    <th>Number of Stops </th>
		    <th>Airline Name(s) </th>
		  </tr>
		  <%
		  String departure = request.getParameter("Source");
		  String arrival = request.getParameter("Destination");
		  String arrival_time = request.getParameter("arrival");
		  String departure_time = request.getParameter("departure");
		  
		  try {
				ApplicationDB db = new ApplicationDB();	
				Connection con = db.getConnection();
			
			    PreparedStatement stmt = con.prepareStatement("SELECT * FROM flights WHERE departure_airport_id = ? AND arrival_airport_id = ? AND DATE(arrival_time) = ? AND DATE(departure_time) = ?");
			    stmt.setString(1, departure);
			    stmt.setString(2, arrival);
			    stmt.setString(3, arrival_time);
			    stmt.setString(4, departure_time);
			    ResultSet rs = stmt.executeQuery();
			
			    while (rs.next()) {
					//make a row
					out.print("<tr>");
					//make a column
					out.print("<td>");
					//Print out current bar name:
					out.print(rs.getString("flight_id"));
					out.print("</td>");
					out.print("<td>");
					//Print out current beer name:
					out.print(rs.getString("departure_time"));
					out.print("</td>");
					out.print("<td>");
					//Print out current price
					out.print(rs.getString("departure_airport_id"));
					out.print("</td>");
					out.print("<td>");
					out.print(rs.getString("arrival_time"));
					out.print("</td>");
					out.print("<td>");
					out.print(rs.getString("arrival_airport_id"));
					out.print("</td>");
					out.print("<td>");
					out.print(0);
					out.print("</td>");
					out.print("<td>");
					out.print(rs.getString("airline_id"));
					out.print("</td>");
					out.print("</tr>");

				}
			  } catch (Exception e) {
			    response.sendRedirect("login.jsp?error=Database+error");
			    return;
			  }
		  %>
		</table>

		
		</body>
</body>
</html>