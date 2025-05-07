<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
	String flight_id = request.getParameter("flight_id2");
	String airline_id = request.getParameter("airline_id2");
	String first_name = request.getParameter("first_name2");
	String last_name = request.getParameter("last_name2"); 
   
        try {
            ApplicationDB db = new ApplicationDB();
            Connection con = db.getConnection();

            StringBuilder query = new StringBuilder(
                    "SELECT t.ticket_id, t.uid, t.first_name, t.last_name, a.flight_id, f.airline_id, t.total_fare, t.booking_fee " +
                    "FROM ticket t " +
                    "JOIN associated_with_ticketflight a ON t.ticket_id = a.ticket_id " +
                    "JOIN flights f ON a.flight_id = f.flight_id AND a.airline_id = f.airline_id " +
                    "WHERE 1=1"
                );

                List<String> params = new ArrayList<String>();

                if (flight_id != null && !flight_id.trim().isEmpty()) {
                    query.append(" AND a.flight_id = ?");
                    params.add(flight_id.trim());
                }

                if (airline_id != null && !airline_id.trim().isEmpty()) {
                    query.append(" AND f.airline_id = ?");
                    params.add(airline_id.trim());
                }

                if (first_name != null && !first_name.trim().isEmpty()) {
                    query.append(" AND t.first_name = ?");
                    params.add(first_name.trim());
                }

                if (last_name != null && !last_name.trim().isEmpty()) {
                    query.append(" AND t.last_name = ?");
                    params.add(last_name.trim());
                }

%>
            <table>
                <tr>
                    <th>Ticket ID</th>
                    <th>Flight ID</th>
                	<th>Airline ID</th>
                    <th>uid</th>
                    <th>First Name</th>
                    <th>Last Name</th>
                    <th>Total Fare</th>
                    <th>Booking Fee</th>
                </tr>
                
<%		
			boolean search = false;
			PreparedStatement stmt = con.prepareStatement(query.toString());
			for (int i = 0; i < params.size(); i++) {
			    stmt.setString(i + 1, params.get(i));
			}
			ResultSet rs = stmt.executeQuery();
			double totalRevenue = 0;
            while (rs.next()) {
            	search = true;
                double total_fare = rs.getDouble("total_fare");
                double booking_fee = rs.getDouble("booking_fee");
                totalRevenue += (total_fare + booking_fee);
%>
                <tr>
                    <td><%= rs.getString("ticket_id") %></td>
                     <td><%= rs.getString("flight_id") %></td>
                     <td><%= rs.getString("airline_id") %></td>
                     <td><%= rs.getInt("uid") %></td>
                    <td><%= rs.getString("first_name") %></td>
                    <td><%= rs.getString("last_name") %></td>
                    <td>$<%= total_fare %></td>
                    <td>$<%= booking_fee %></td>
                </tr>
<%
            }

            if (!search) {
%>
                <tr><td colspan="8">No revenue found for this month.</td></tr>
<%
            } else {
%>
                <tr><td colspan="8"><strong>Total Revenue:</strong> $<%= totalRevenue %></td></tr>
  <%              

            }
            %>
            </table>
      <%  
            rs.close();
            stmt.close();
            con.close();
        } catch (Exception e) {
            out.println("<p>Error generating revenue.</p>");
        }
    
%>