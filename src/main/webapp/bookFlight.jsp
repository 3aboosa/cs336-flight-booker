<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);

  if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String flightId = request.getParameter("flight_id");
  String airlineId = request.getParameter("airline_id");

  if (flightId == null || airlineId == null) {
    out.println("<p style='color:red;'>Invalid flight selection.</p>");
    return;
  }
%>

<html>
<head>
  <title>Book Flight</title>
</head>
<body>
  <h2>Confirm Flight Booking</h2>

  <form method="post" action="handleBooking.jsp">
    <input type="hidden" name="flight_id" value="<%= flightId %>" />
    <input type="hidden" name="airline_id" value="<%= airlineId %>" />

    <label for="class">Select Class:</label>
    <select name="class" required>
      <option value="Economy">Economy</option>
      <option value="Business">Business</option>
      <option value="First">First</option>
    </select>

    <br><br>
    <input type="submit" value="Confirm Booking" />
  </form>
</body>
</html>
