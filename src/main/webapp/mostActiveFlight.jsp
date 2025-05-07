<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
   
        try {
            ApplicationDB db = new ApplicationDB();
            Connection con = db.getConnection();

            String query = "SELECT a.flight_id, f.airline_id, COUNT(t.ticket_id) AS total_tickets " +
                    "FROM ticket t, flights f, associated_with_ticketflight a " +
                    "WHERE a.airline_id= f.airline_id AND t.ticket_id = a.ticket_id AND a.flight_id = f.flight_id " +
                    "GROUP BY a.flight_id, f.airline_id ORDER BY total_tickets DESC LIMIT 5";
%>
            <table>
                <tr>
              
                    <th>Flight ID</th>
                    <th>Airline ID</th>
                    <th>Total Tickets Sold </th>
                </tr>
                
<%			
			PreparedStatement stmt = con.prepareStatement(query);
			ResultSet rs = stmt.executeQuery();
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
            if (!search){
%>
                <tr><td colspan="3"><strong>No Flights Found.</strong> </td></tr>
  <%              

            }
            %>
            </table>
      <%  
            rs.close();
            stmt.close();
            con.close();
        } catch (Exception e) {
            out.println("<p>Error generating Top Flights.</p>");
        }
    
%>