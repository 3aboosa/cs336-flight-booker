<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
	String salesMonth = request.getParameter("sales_month");
	
    try {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();

        String query = "SELECT * FROM ticket WHERE DATE_FORMAT(Purchase_DateTime, '%Y-%m') = ?";
        PreparedStatement stmt = con.prepareStatement(query);
        stmt.setString(1, salesMonth);

        ResultSet rs = stmt.executeQuery();
        double total_sales = 0;
        boolean search = false;
	%>
	<table>
	    <tr>
	        <th>Ticket ID</th>
	        <th>uid</th>
	        <th>First Name</th>
	        <th>Last Name</th>
	        <th>Class</th>
	        <th>Total Fare</th>
	        <th>Booking Fee</th>
	        <th>Purchase Date</th>
	    </tr>
	<%
	        while (rs.next()) {
	            search = true;
	            double total_fare = rs.getDouble("Total_Fare");
	            double booking_fee = rs.getDouble("Booking_Fee");
	            total_sales += (total_fare + booking_fee);
	%>
	    <tr>
	        <td><%= rs.getString("Ticket_ID") %></td>
	        <td><%= rs.getInt("uid") %></td>
	        <td><%= rs.getString("First_Name") %></td>
	        <td><%= rs.getString("Last_Name") %></td>
	        <td><%= rs.getString("Class") %></td>
	        <td>$<%= total_fare %></td>
	        <td>$<%= booking_fee %></td>
	        <td><%= rs.getTimestamp("Purchase_DateTime") %></td>
	    </tr>
	<%
	        }
	
	        if (!search) {
%>
	    <tr><td colspan="8">No sales found for this month.</td></tr>
<%
	        } else {
	%>
	    <tr><td colspan="8"><strong>Total Sales:</strong> $<%= total_sales %></td></tr>
<%
	        }
	%>
	
<%
	        rs.close();
	        stmt.close();
	        con.close();
	    } catch (Exception e) {
	        out.println("<p>Error generating sales.</p>");
	    }
%>
</table>