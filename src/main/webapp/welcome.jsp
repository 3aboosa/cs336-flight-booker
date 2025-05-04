<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
  <title>Welcome</title>
  <style>
    table {
      font-family: arial, sans-serif;
      border-collapse: collapse;
      width: 100%;
    }

    td, th {
      border: 1px solid #dddddd;
      text-align: left;
      padding: 8px;
    }

    tr:nth-child(even) {
      background-color: #dddddd;
    }
  </style>
</head>

<body style="margin: 0; padding: 0; box-sizing: border-box; font-family: Arial, sans-serif;">

<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);

  if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String username = (String) session.getAttribute("username");
  String firstName = "";

  try {
    ApplicationDB db = new ApplicationDB();	
    Connection con = db.getConnection();

    PreparedStatement stmt = con.prepareStatement("SELECT first_name FROM individual WHERE username = ?");
    stmt.setString(1, username);
    ResultSet rs = stmt.executeQuery();

    if (rs.next()) {
      firstName = rs.getString("first_name");
    }

    rs.close();
    stmt.close();
    con.close();
  } catch (Exception e) {
    out.println("Error: " + e.getMessage());
  }
%>

<div style="margin: 10px;">
  <a href="handleLogout.jsp">Logout</a>
  <a href="myFlights.jsp">View My Flights</a>
  <a href="browseQuestions.jsp">Questions & Answers</a>
</div>

<h1>Welcome, <%= firstName %>!</h1>

<form method="get">
  <label for="Source">From:</label>
  <input type="text" id="Source" name="Source">
  <label for="Destination">To:</label>
  <input type="text" id="Destination" name="Destination">

  <label for="departure">Departure:</label>
  <input type="date" id="departure" name="departure" required>

  <label for="arrival">Arrival:</label>
  <input type="date" id="arrival" name="arrival" required>

  <input type="checkbox" id="FlexibleDates" name="FlexibleDates">
  <label for="FlexibleDates">Flexible Dates (+/- 3 Days)</label>

  <button type="submit">Search</button>
</form>

<h2>Available Flights</h2>

<table>
  <tr>
    <th>Flight ID</th>
    <th>Departure Time</th>
    <th>Departure Location</th>
    <th>Arrival Time</th>
    <th>Arrival Location</th>
    <th>Number of Stops</th>
    <th>Airline</th>
    <th>Book Flight</th>
  </tr>

<%
  String departure = request.getParameter("Source");
  String arrival = request.getParameter("Destination");
  String arrival_time = request.getParameter("arrival");
  String departure_time = request.getParameter("departure");

  if (departure != null && arrival != null && arrival_time != null && departure_time != null) {
    try {
      ApplicationDB db = new ApplicationDB();	
      Connection con = db.getConnection();

      PreparedStatement stmt = con.prepareStatement(
        "SELECT * FROM flights WHERE departure_airport_id = ? AND arrival_airport_id = ? AND DATE(arrival_time) = ? AND DATE(departure_time) = ?"
      );
      stmt.setString(1, departure);
      stmt.setString(2, arrival);
      stmt.setString(3, arrival_time);
      stmt.setString(4, departure_time);
      ResultSet rs = stmt.executeQuery();

      while (rs.next()) {
        String flightId = rs.getString("flight_id");
        String airlineId = rs.getString("airline_id");

        out.print("<tr>");
        out.print("<td>" + flightId + "</td>");
        out.print("<td>" + rs.getString("departure_time") + "</td>");
        out.print("<td>" + rs.getString("departure_airport_id") + "</td>");
        out.print("<td>" + rs.getString("arrival_time") + "</td>");
        out.print("<td>" + rs.getString("arrival_airport_id") + "</td>");
        out.print("<td>0</td>");
        out.print("<td>" + airlineId + "</td>");
        out.print("<td>");

        // Seat availability check
        PreparedStatement seatStmt = con.prepareStatement(
          "SELECT a.number_of_seats AS capacity, " +
          "(SELECT COUNT(*) FROM associated_with_ticketflight awtf " +
          " JOIN ticket t ON awtf.Ticket_ID = t.Ticket_ID " +
          " WHERE awtf.flight_id = ? AND awtf.airline_id = ? AND t.Status = 'Confirmed') AS booked " +
          "FROM flights f " +
          "JOIN aircraft a ON f.aircraft_id = a.aircraft_id " +
          "WHERE f.flight_id = ? AND f.airline_id = ?"
        );
        seatStmt.setString(1, flightId);
        seatStmt.setString(2, airlineId);
        seatStmt.setString(3, flightId);
        seatStmt.setString(4, airlineId);
        ResultSet seatRs = seatStmt.executeQuery();

        boolean isFull = false;
        if (seatRs.next()) {
          int capacity = seatRs.getInt("capacity");
          int booked = seatRs.getInt("booked");
          isFull = (booked >= capacity);
        }

        seatRs.close();
        seatStmt.close();

        if (isFull) {
          out.print("<a href='handleWaitlist.jsp?flight_id=" + flightId +
                    "&airline_id=" + airlineId + "&class=Economy&reason=full'>Join Waitlist</a>");
        } else {
          out.print("<a href='bookFlight.jsp?flight_id=" + flightId +
                    "&airline_id=" + airlineId + "'>Book</a>");
        }

        out.print("</td>");
        out.print("</tr>");
      }

      rs.close();
      stmt.close();
      con.close();
    } catch (Exception e) {
      response.sendRedirect("welcome.jsp?error=Database+error");
      return;
    }
  }
%>
</table>

</body>
</html>
