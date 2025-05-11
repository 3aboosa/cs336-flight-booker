<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
String username = request.getParameter("username");
String firstName = request.getParameter("first_name");
String lastName = request.getParameter("last_name");
String phoneNumber = request.getParameter("phone_number");

try {
    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    PreparedStatement stmt = con.prepareStatement("SELECT uid FROM individual WHERE username = ?");
    stmt.setString(1, username);
    ResultSet rs = stmt.executeQuery();

    if (!rs.next()) {
        rs.close();
        stmt.close();
        con.close();
        response.sendRedirect("admin.jsp?error=User+not+found");
        return;
    }

    int uid = rs.getInt("uid");
    rs.close();
    stmt.close();

  
    PreparedStatement stmt2 = con.prepareStatement("UPDATE individual SET first_name = ?, last_name = ? WHERE uid = ?");
    stmt2.setString(1, firstName);
    stmt2.setString(2, lastName);
    stmt2.setInt(3, uid);
    int update = stmt2.executeUpdate();
    stmt2.close();

  
    PreparedStatement stmt3 = con.prepareStatement("SELECT uid FROM customer WHERE uid = ?");
    stmt3.setInt(1, uid);
    ResultSet rs2 = stmt3.executeQuery();
    boolean checkRole = rs2.next();  
    rs2.close();
    stmt3.close();

 
    if (checkRole && phoneNumber != null && !phoneNumber.trim().isEmpty()) {
        PreparedStatement stmt4 = con.prepareStatement("UPDATE customer SET phone_number = ? WHERE uid = ?");
        stmt4.setString(1, phoneNumber);
        stmt4.setInt(2, uid);
        stmt4.executeUpdate();
        stmt4.close();
    }

    con.close();
    
    if (update > 0) {
        response.sendRedirect("admin.jsp?success=User+updated");
    } else {
        response.sendRedirect("admin.jsp?error=No+changes+made");
    }

} catch (Exception e) {
    response.sendRedirect("admin.jsp?error=Error+updating+user:+" + e.getMessage());
}
%>