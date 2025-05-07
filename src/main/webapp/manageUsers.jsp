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
	    	</tr>
	    
<% 
	    while (rs.next()) {
	    	search = true;
	    	%>
			<tr> 
			<td><%= rs.getInt("uid") %></td>
			
			<td><%= rs.getString("username") %></td>
			<td><%= rs.getString("password") %></td>
			<td><%= rs.getString("first_name") %></td>
			<td><%= rs.getString("last_name") %></td>
			<td>
				<form method = "post" action ="deleteUser.jsp" style = "display:inline;">
					<input type ="hidden" name="uid" value="<%=rs.getInt("uid") %>">
					<button type ="submit" onclick="return confirm('Are you sure you want to delete this user?')">Delete</button>
				
				</form>
			
			</td>
			
			</tr>
<%
		}
		if (!search){
			out.println("<tr><td colspan='5'>No users found.</td></tr>");
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