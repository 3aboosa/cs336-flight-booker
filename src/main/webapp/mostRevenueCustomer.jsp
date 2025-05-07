<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
   
        try {
            ApplicationDB db = new ApplicationDB();
            Connection con = db.getConnection();

            String query = 
                    "SELECT t.uid, i.first_name, i.last_name, SUM(t.total_fare + t.booking_fee) AS total_revenue " +
                    "FROM ticket t, individual i WHERE i.uid = t.uid GROUP BY t.uid " +
                    "ORDER BY total_revenue DESC LIMIT 1";
%>
            <table>
                <tr>
              
                    <th>uid</th>
                    <th>First Name</th>
                    <th>Last Name</th>
                    <th>Total Revenue</th>
                </tr>
                
<%			
			PreparedStatement stmt = con.prepareStatement(query);
			ResultSet rs = stmt.executeQuery();
		
          

            if (rs.next()) {
%>
               <tr>
               <td><%= rs.getInt("uid") %></td>
               <td><%= rs.getString("first_name") %></td>
               <td><%= rs.getString("last_name") %></td>
               <td>$<%= rs.getDouble("total_revenue") %></td>
          		 </tr>
<%
            } else {
%>
                <tr><td colspan="4"><strong>No Revenue Found.</strong> </td></tr>
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