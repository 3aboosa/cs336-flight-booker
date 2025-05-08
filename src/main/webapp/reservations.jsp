<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>


<%
    String flight_id = request.getParameter("flight_id");
    String first_name = request.getParameter("first_name");
    String last_name = request.getParameter("last_name");

    try {
	    ApplicationDB db = new ApplicationDB();
	    Connection con = db.getConnection();
	
	    StringBuilder query = new StringBuilder(
	        "SELECT f.flight_id, t.ticket_id, t.uid, t.first_name, t.last_name, f.departure_airport_id, f.arrival_airport_id " +
	        "FROM ticket t, flights f, associated_with_ticketflight a " +
	        "WHERE a.flight_id = f.flight_id AND a.airline_id = f.airline_id AND a.ticket_id = t.ticket_id"
	    );
	
	    List<String> searches = new ArrayList<String>();
	
	    if (flight_id != null && !flight_id.trim().isEmpty()) {
	        query.append(" AND f.flight_id = ?");
	        searches.add(flight_id.trim());
	    }
	
	    if (first_name != null && !first_name.trim().isEmpty()) {
	        query.append(" AND t.first_name = ?");
	        searches.add(first_name.trim());
	    }
	
	    if (last_name != null && !last_name.trim().isEmpty()) {
	        query.append(" AND t.last_name = ?");
	        searches.add(last_name.trim());
	    }
	    if (searches.size() == 0) {
	        out.println("<p style='color:red'>Please enter Flight ID and/or Name.</p>");
	        return;
	    }
	
	    PreparedStatement stmt = con.prepareStatement(query.toString());
	    for (int i = 0; i < searches.size(); i++) {
	        stmt.setString(i + 1, searches.get(i));
	    }
	
	    ResultSet rs = stmt.executeQuery();
	    boolean found = false;
	%>
	
		<table>
		  <tr>
		    <th>Flight ID</th>
		    <th>Ticket ID</th>
		    <th>UID</th>
		    <th>First Name</th>
		    <th>Last Name</th>
		    <th>Departure Airport</th>
		    <th>Arrival Airport</th>
		  </tr>
	
	<%
	    while (rs.next()) {
	        found = true;
	%>
		  <tr>
		    <td><%= rs.getString("flight_id") %></td>
		    <td><%= rs.getString("ticket_id") %></td>
		    <td><%= rs.getString("uid") %></td>
		    <td><%= rs.getString("first_name") %></td>
		    <td><%= rs.getString("last_name") %></td>
		    <td><%= rs.getString("departure_airport_id") %></td>
		    <td><%= rs.getString("arrival_airport_id") %></td>
		  </tr>
	<%
	    }
	    if (!found) {
	        out.println("<tr><td colspan='7'>No reservations found.</td></tr>");
	    }
	
	    rs.close();
	    stmt.close();
	    con.close();
    } catch (Exception e) {
        out.println("<p>Error generating revenue. " + e.getMessage() + "</p>");
    }
%>
</table>