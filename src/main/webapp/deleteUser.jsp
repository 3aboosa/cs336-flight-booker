<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>


<%
	String uidrs = request.getParameter("uid");
	
	if (uidrs ==null || uidrs.isEmpty() ){
		response.sendRedirect("admin.jsp");
		return;
	}
	int uid = Integer.parseInt(uidrs);
	try{
		ApplicationDB db = new ApplicationDB();
		Connection con = db.getConnection();
		
		PreparedStatement stmt = con.prepareStatement("DELETE FROM individual WHERE uid = ?");
		stmt.setInt(1, uid);
		stmt.executeUpdate();
		stmt.close();
		con.close();
		response.sendRedirect("admin.jsp");
	} catch (Exception e){
		response.sendRedirect("admin.jsp?error=delete+error");
	}


%>