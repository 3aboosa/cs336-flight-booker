<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.sql.*,javax.servlet.http.*,javax.servlet.*" %>

<%
  String questionText = request.getParameter("question_text");

  if (session.getAttribute("username") == null || questionText == null || questionText.trim().equals("")) {
    response.sendRedirect("askQuestion.jsp?error=Missing+question");
    return;
  }

  try {
    String username = (String) session.getAttribute("username");

    ApplicationDB db = new ApplicationDB();	
    Connection con = db.getConnection();

    PreparedStatement uidStmt = con.prepareStatement("SELECT uid FROM individual WHERE username = ?");
    uidStmt.setString(1, username);
    ResultSet rs = uidStmt.executeQuery();

    int uid = -1;
    if (rs.next()) {
      uid = rs.getInt("uid");
    }

    if (uid != -1) {
      PreparedStatement insertStmt = con.prepareStatement("INSERT INTO question (uid, question_text) VALUES (?, ?)");
      insertStmt.setInt(1, uid);
      insertStmt.setString(2, questionText);
      insertStmt.executeUpdate();
      insertStmt.close();
    }

    rs.close();
    uidStmt.close();
    con.close();

    response.sendRedirect("browseQuestions.jsp");

  } catch (Exception e) {
    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
  }
%>
