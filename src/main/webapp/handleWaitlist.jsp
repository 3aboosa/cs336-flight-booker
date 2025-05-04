<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
  if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String reason = request.getParameter("reason");
	
  if ("full".equals(reason)) {
    out.println("<p style='color:orange; font-weight: bold;'>This flight is full. You've been placed on the waitlist.</p>");
  }


  String username = (String) session.getAttribute("username");
  String flightId = request.getParameter("flight_id");
  String airlineId = request.getParameter("airline_id");
  String seatClass = request.getParameter("class");

  try {
    ApplicationDB db = new ApplicationDB();	
    Connection con = db.getConnection();

    // Get user info
    PreparedStatement userStmt = con.prepareStatement("SELECT uid, first_name, last_name FROM individual WHERE username = ?");
    userStmt.setString(1, username);
    ResultSet userRs = userStmt.executeQuery();

    if (!userRs.next()) {
      response.sendRedirect("login.jsp?error=User+not+found");
      return;
    }

    int uid = userRs.getInt("uid");
    String fname = userRs.getString("first_name");
    String lname = userRs.getString("last_name");

    // Ensure user is in customer
    PreparedStatement checkCustomer = con.prepareStatement("SELECT * FROM customer WHERE uid = ?");
    checkCustomer.setInt(1, uid);
    ResultSet custRs = checkCustomer.executeQuery();

    if (!custRs.next()) {
      PreparedStatement insertCustomer = con.prepareStatement("INSERT INTO customer (uid) VALUES (?)");
      insertCustomer.setInt(1, uid);
      insertCustomer.executeUpdate();
    }

    // Generate Ticket ID
    String ticketId = "T-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

    // Insert waitlisted ticket
    PreparedStatement ticketStmt = con.prepareStatement(
      "INSERT INTO ticket (Ticket_ID, First_Name, Last_Name, Status, Seat_Number, Total_Fare, Purchase_DateTime, Booking_Fee, Class, uid) " +
      "VALUES (?, ?, ?, 'Waitlisted', NULL, 0.00, NOW(), 0.00, ?, ?)"
    );
    ticketStmt.setString(1, ticketId);
    ticketStmt.setString(2, fname);
    ticketStmt.setString(3, lname);
    ticketStmt.setString(4, seatClass);
    ticketStmt.setInt(5, uid);
    ticketStmt.executeUpdate();

    // Link to flight
    PreparedStatement assocStmt = con.prepareStatement(
      "INSERT INTO associated_with_ticketflight (flight_id, Ticket_ID, airline_id) VALUES (?, ?, ?)"
    );
    assocStmt.setString(1, flightId);
    assocStmt.setString(2, ticketId);
    assocStmt.setString(3, airlineId);
    assocStmt.executeUpdate();

    out.println("<p style='color:orange;'>You have been added to the waitlist for flight " + flightId + ".</p>");
    con.close();
  } catch (Exception e) {
    out.println("<p style='color:red;'>Waitlist failed: " + e.getMessage() + "</p>");
  }
%>
