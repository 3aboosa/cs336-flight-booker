<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<html>
<head>
  <title>Browse QA</title>
</head>
<body style="font-family: Arial; padding: 20px;">
  <h1>Browse Questions and Answers</h1>
  
  <a href="askQuestion.jsp" style="display:inline-block; margin-bottom: 20px;">Ask a Question</a>

  <form method="get" action="searchQuestions.jsp">
    <input type="text" name="keyword" placeholder="Search questions..." required>
    <input type="submit" value="Search">
  </form>

  <%
    try {
      ApplicationDB db = new ApplicationDB();
      Connection con = db.getConnection();

      PreparedStatement stmt = con.prepareStatement(
        "SELECT q.question_id, q.question_text, q.timestamp, i.first_name, i.last_name, " +
        "a.answer_text, a.timestamp AS answer_time, r.first_name AS rep_fname, r.last_name AS rep_lname " +
        "FROM question q " +
        "JOIN individual i ON q.uid = i.uid " +
        "LEFT JOIN answer a ON q.question_id = a.question_id " +
        "LEFT JOIN individual r ON a.rep_uid = r.uid " +
        "ORDER BY q.timestamp DESC"
      );

      ResultSet rs = stmt.executeQuery();

      while (rs.next()) {
  %>
    <div style="border: 1px solid gray; padding: 10px; margin-bottom: 10px;">
      <p><strong>Q:</strong> <%= rs.getString("question_text") %></p>
      <p style="color:gray;">Asked by <%= rs.getString("first_name") %> <%= rs.getString("last_name") %> on <%= rs.getString("timestamp") %></p>

      <% if (rs.getString("answer_text") != null) { %>
        <p><strong>A:</strong> <%= rs.getString("answer_text") %></p>
        <p style="color:gray;">Answered by <%= rs.getString("rep_fname") %> <%= rs.getString("rep_lname") %> on <%= rs.getString("answer_time") %></p>
      <% } else { %>
        <p style="color:red;">No answer yet.</p>
      <% } %>
    </div>
  <%
      }

      rs.close();
      stmt.close();
      con.close();
    } catch (Exception e) {
      out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
  %>
</body>
</html>