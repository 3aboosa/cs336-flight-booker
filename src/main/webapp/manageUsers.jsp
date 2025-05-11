<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>


<%

  String searchUser = request.getParameter("manageSearch");
if (searchUser != null && !searchUser.trim().isEmpty()) {
  try {
		ApplicationDB db = new ApplicationDB();	
		Connection con = db.getConnection();
	    PreparedStatement stmt = con.prepareStatement("SELECT * FROM individual WHERE username LIKE ? OR first_name LIKE ? OR last_name LIKE ?");
	    String search_rs = "%" + searchUser + "%";
	    stmt.setString(1, search_rs);
	    stmt.setString(2, search_rs);
	    stmt.setString(3, search_rs);
	    ResultSet rs = stmt.executeQuery();
	    boolean search = false;
%>
	    <table>
	    	<tr>
	    		<th> uid </th>
	    		<th> username </th>
	    		<th> password </th>
	    		<th> First Name </th>
	    	
	    		<th> Last Name </th>
	    		<th>Phone Number</th>
	    	</tr>
	    
<% 
	    while (rs.next()) {
	    	 search = true;
             String username = rs.getString("username");
             int uid = rs.getInt("uid");
             String firstName = rs.getString("first_name");
             String lastName = rs.getString("last_name");
             String password = rs.getString("password");
             String phoneNumber = "";  
             
            
             PreparedStatement stmt2 = con.prepareStatement("SELECT phone_number FROM customer WHERE uid = ?");
             stmt2.setInt(1, uid);
             ResultSet rs2 = stmt2.executeQuery();
             
             if (rs2.next()) {
                 phoneNumber = rs2.getString("phone_number");  
             }

             rs2.close();
%>
             <tr> 
                 <td><%= uid %></td>
                 <td><%= username %></td>
                 <td><%= password %></td>
                 <td><%= firstName %></td>
                 <td><%= lastName %></td>
                 <td><%= phoneNumber %></td> 
                 <td>
                     <form method="post" action="deleteUser.jsp" style="display:inline;">
                         <input type="hidden" name="uid" value="<%= uid %>">
                         <button type="submit" onclick="return confirm('Are you sure you want to delete this user?')">Delete</button>
                     </form>
                     <a href="editUser.jsp?username=<%= username %>">
                         <button>Edit</button>
                     </a>
                 </td>
             </tr>
<%
         }
         if (!search) {
             out.println("<tr><td colspan='7'>No users found.</td></tr>");
         }
%>
     </table>
<% 
     rs.close();
     stmt.close();
     con.close();
 } catch (Exception e) {
     response.sendRedirect("admin.jsp?error=Search+error");
     return;
 }
}
%>