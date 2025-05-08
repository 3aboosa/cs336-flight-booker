<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
	String mostRevenue = request.getParameter("mostRevenueCustomer");
	String generateType = request.getParameter("generateType");
	
	
	String startDate = request.getParameter("startDate");
	String endDate = request.getParameter("endDate");
	String topCount = request.getParameter("topCount");
	
	
	boolean isAllTime = generateType.equals("allTime");
	boolean isDateRange = generateType.equals("dateRange") && startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty();
	
	if (!isAllTime && !isDateRange) {
	    out.println("<p style=\"color: red;\"> Please provide both start date and end date for date range search.</p>");
	    return;
	}
	
	String query = "";
	
	if (isDateRange) {
	    query = "SELECT t.uid, i.first_name, i.last_name, SUM(t.total_fare + t.booking_fee) AS total_revenue " +
	    "FROM ticket t, individual i WHERE i.uid = t.uid " +
	    "AND t.purchase_datetime BETWEEN ? AND ? GROUP BY t.uid " +
	    "ORDER BY total_revenue DESC LIMIT ?";
	} else if (isAllTime) {
	    query = "SELECT t.uid, i.first_name, i.last_name, SUM(t.total_fare + t.booking_fee) AS total_revenue " +
	    "FROM ticket t, individual i WHERE i.uid = t.uid " +
	    "GROUP BY t.uid ORDER BY total_revenue DESC LIMIT ?";
	}
	
	
	try {
	    ApplicationDB db = new ApplicationDB();
	    Connection con = db.getConnection();
	
	    PreparedStatement stmt = con.prepareStatement(query);
	    int index = 1;
	
	    if (isDateRange) {
	    	
	        stmt.setString(index++, startDate);
	        stmt.setString(index++, endDate);
	    }
	    stmt.setInt(index, Integer.parseInt(topCount)); 
	
	    ResultSet rs = stmt.executeQuery();
	   
	%>
	
	<table>
	    <tr>
	        <th>UID</th>
	        <th>First Name</th>
	        <th>Last Name</th>
	        <th>Total Revenue</th>
	    </tr>
	
	<%
	 	boolean search = false;
	    while (rs.next()) {
	        search = true;
	%>
	    <tr>
	        <td><%= rs.getInt("uid") %></td>
	        <td><%= rs.getString("first_name") %></td>
	        <td><%= rs.getString("last_name") %></td>
	        <td>$<%= rs.getDouble("total_revenue") %></td>
	    </tr>
	<%
	    }
	
	    if (!search) {
	%>
	    <tr><td colspan="4"><strong>No Revenue Found.</strong></td></tr>
	<%
	    }
	    
	    rs.close();
	    stmt.close();
	    con.close();
	} catch (Exception e) {
	    out.println("<p style=\"color: red;\">Error generating revenue. " + e.getMessage() + "</p>");
	}
	%>
</table>