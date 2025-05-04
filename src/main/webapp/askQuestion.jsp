<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
  if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
  }
%>

<html>
<head>
  <title>Ask a Question</title>
</head>
<body style="font-family: Arial; padding: 20px;">
  <h1>Submit a Question</h1>

  <form method="post" action="handleAsk.jsp">
    <label for="question_text">Your Question:</label><br>
    <textarea name="question_text" rows="5" cols="60" required></textarea><br><br>
    <button type="submit">Submit</button>
  </form>
</body>
</html>
