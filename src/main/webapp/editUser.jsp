<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>


<%
String username = request.getParameter("username");
String firstName = "";
String lastName = "";
String phoneNumber = "";
int uid = 0;
boolean checkRole = false;
	try {
	    ApplicationDB db = new ApplicationDB();
	    Connection con = db.getConnection();
	
	    PreparedStatement stmt = con.prepareStatement("SELECT uid, first_name, last_name FROM individual WHERE username = ?");
	    stmt.setString(1, username);
	    ResultSet rs = stmt.executeQuery();
	
	    if (rs.next()) {
	    	uid = rs.getInt("uid");
	        firstName = rs.getString("first_name");
	        lastName = rs.getString("last_name");
	    }
	
	    rs.close();
	    stmt.close();
	
	    PreparedStatement stmt2 = con.prepareStatement("SELECT phone_number FROM customer WHERE uid = ?");
	    stmt2.setInt(1, uid);
	    ResultSet rs2 = stmt2.executeQuery();
	
	    if (rs2.next()) {
	        checkRole = true;
	        phoneNumber = rs2.getString("phone_number");
	        if (phoneNumber == null) {
	            phoneNumber = "";
	        }
	    }
	    rs2.close();
	    stmt2.close();
	    con.close();
	} catch (Exception e) {
	    response.sendRedirect("admin.jsp?error=Error+loading+user:+" + e.getMessage());
	    return;
	}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Edit User</title>
</head>
<body>

    <h2>Edit User: <%= username %></h2>

    <form method="post" action="updateUser.jsp">
        <input type="hidden" name="username" value="<%= username %>">

        <label for="first_name">First Name:</label>
        <input type="text" name="first_name" value="<%= firstName %>" required><br><br>

        <label for="last_name">Last Name:</label>
        <input type="text" name="last_name" value="<%= lastName %>" required><br><br>
        <% if (checkRole) { %>
        <div class="form-group">
            <label for="phone_number">Phone:</label>
            <input type="text" name="phone_number" id="phone_number" value="<%= phoneNumber %>">
        </div>
        <% } %>

        <button type="submit">Update User</button>
    </form>

</body>
</html>