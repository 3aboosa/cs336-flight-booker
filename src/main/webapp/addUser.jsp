<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>


<%
	String username = request.getParameter("add_username");
	String password = request.getParameter("add_password");
	String first_name = request.getParameter("add_first_name");
	String last_name = request.getParameter("add_last_name");
	String role = request.getParameter("role");
	String phone_number = request.getParameter("phone_number");
	
	if (username == null || password ==null || first_name == null || last_name == null || role == null ){
		response.sendRedirect("admin.jsp?error=Missing+fields");
		return;
	}
	
	try{
		ApplicationDB db = new ApplicationDB();
		Connection con = db.getConnection();

		PreparedStatement stmt2 = con.prepareStatement("INSERT INTO individual (username, password, first_name, last_name) VALUES (?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
		int uid = -1;
		stmt2.setString(1, username);
		stmt2.setString(2, password);
		stmt2.setString(3, first_name);
		stmt2.setString(4, last_name);
		stmt2.executeUpdate();
		ResultSet rs = stmt2.getGeneratedKeys();
		if (rs.next()){
			uid = rs.getInt(1);
		}
		stmt2.close();
		rs.close();
		
		if (role.equals("admin")){
			PreparedStatement stmt3 = con.prepareStatement("INSERT INTO admin (uid) VALUES (?)");
			stmt3.setInt(1, uid);
			stmt3.executeUpdate();
			stmt3.close();
		} else if (role.equals("customerrepresentative")){
			PreparedStatement stmt3 = con.prepareStatement("INSERT INTO customerrepresentative (uid) VALUES (?)");
			stmt3.setInt(1, uid);
			stmt3.executeUpdate();
			stmt3.close();
		} else if (role.equals("customer")){
			PreparedStatement stmt3 = con.prepareStatement("INSERT INTO customer (uid, phone_number) VALUES (?, ?)");
			stmt3.setInt(1, uid);
			stmt3.setString(2, (phone_number == null || phone_number.isEmpty() ? null: phone_number));
			stmt3.executeUpdate();
			stmt3.close();
		}
		 
		
		
		con.close();
		response.sendRedirect("admin.jsp");
	} catch (Exception e){
		response.sendRedirect("admin.jsp?error=addUser+error");
	}


%>