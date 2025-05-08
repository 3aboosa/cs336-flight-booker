<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
	String mostActiveFlight = request.getParameter("mostActiveFlight");
	String flightGenerateType = request.getParameter("flightGenerateType");
	
	String flightStartDate = request.getParameter("flightStartDate");
	String flightEndDate = request.getParameter("flightEndDate");
	String count = request.getParameter("topFlightCount");
	
	boolean isFlightAllTime = flightGenerateType.equals("flightAllTime");
	boolean isFlightTimeRange = flightGenerateType.equals("flightDateRange") &&  flightStartDate != null && !flightStartDate.isEmpty() && 
	                        flightEndDate != null && !flightEndDate.isEmpty();
	
	if (!isFlightAllTime && !isFlightTimeRange) {
	    out.println("<p style=\"color: red;\">Error: Please provide both start date and end date for date range search.</p>");
	    return;
	}
	
	String query = "";
	
	if (isFlightTimeRange) {
	    query = "SELECT a.flight_id, f.airline_id, COUNT(t.ticket_id) AS total_tickets FROM ticket t, flights f, associated_with_ticketflight a " +
	            "WHERE a.airline_id = f.airline_id AND t.ticket_id = a.ticket_id AND a.flight_id = f.flight_id " +
	            "AND t.purchase_datetime BETWEEN ? AND ? " +
	            "GROUP BY a.flight_id, f.airline_id ORDER BY total_tickets DESC LIMIT ?";
	} else if (isFlightAllTime) {
	    query = "SELECT a.flight_id, f.airline_id, COUNT(t.ticket_id) AS total_tickets FROM ticket t, flights f, associated_with_ticketflight a " +
	            "WHERE a.airline_id = f.airline_id AND t.ticket_id = a.ticket_id AND a.flight_id = f.flight_id " +
	            "GROUP BY a.flight_id, f.airline_id ORDER BY total_tickets DESC LIMIT ?";
	}
	
	try {
	    ApplicationDB db = new ApplicationDB();
	    Connection con = db.getConnection();
	
	    PreparedStatement stmt = con.prepareStatement(query);
	    int index = 1;
	    if (isFlightTimeRange) {
	    	
	        stmt.setString(index++, flightStartDate);
	        stmt.setString(index++, flightEndDate);
	    }
	    stmt.setInt(index, Integer.parseInt(count)); 
	
	    ResultSet rs = stmt.executeQuery();
	    
	%>
	
	<table>
	    <tr>
	        <th>Flight ID</th>
	        <th>Airline ID</th>
	        <th>Total Tickets Sold</th>
	    </tr>
	
	<%
		boolean search = false;
	    while (rs.next()) {
	    	search = true;
	%>
	    <tr>
	        <td><%= rs.getInt("flight_id") %></td>
	        <td><%= rs.getString("airline_id") %></td>
	        <td><%= rs.getInt("total_tickets") %></td>
	    </tr>
	<%
	    }
	
	    if (!search) {
	%>
	    <tr><td colspan="3"><strong>No Flights Found.</strong></td></tr>
	<%
	    }
	%>
	</table>
	
	<%
	    rs.close();
	    stmt.close();
	    con.close();
	} catch (Exception e) {
	    out.println("<p style=\"color: red;\">Error generating Top Active Flights. " + e.getMessage() + "</p>");
	}
%>