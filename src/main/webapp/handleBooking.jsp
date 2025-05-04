<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
  if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
    return;
  }

  String username = (String) session.getAttribute("username");
  String flightId = request.getParameter("flight_id");
  String airlineId = request.getParameter("airline_id");
  String seatClass = request.getParameter("class");

  try {
    ApplicationDB db = new ApplicationDB();	
    Connection con = db.getConnection();

    // Get user info from individual
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

    // Ensure user is in customer table
    PreparedStatement checkCustomer = con.prepareStatement("SELECT * FROM customer WHERE uid = ?");
    checkCustomer.setInt(1, uid);
    ResultSet custRs = checkCustomer.executeQuery();

    if (!custRs.next()) {
      PreparedStatement insertCustomer = con.prepareStatement("INSERT INTO customer (uid) VALUES (?)");
      insertCustomer.setInt(1, uid);
      insertCustomer.executeUpdate();
    }
    
    
 	// Check if flight is full
    PreparedStatement seatCheckStmt = con.prepareStatement(
      "SELECT a.number_of_seats AS capacity, " +
      "(SELECT COUNT(*) FROM associated_with_ticketflight awtf " +
      " JOIN ticket t ON awtf.Ticket_ID = t.Ticket_ID " +
      " WHERE awtf.flight_id = ? AND awtf.airline_id = ? AND t.Status = 'Confirmed') AS booked " +
      "FROM flights f " +
      "JOIN aircraft a ON f.aircraft_id = a.aircraft_id " +
      "WHERE f.flight_id = ? AND f.airline_id = ?"
    );
    seatCheckStmt.setString(1, flightId);
    seatCheckStmt.setString(2, airlineId);
    seatCheckStmt.setString(3, flightId);
    seatCheckStmt.setString(4, airlineId);

    ResultSet seatRs = seatCheckStmt.executeQuery();

    if (seatRs.next()) {
      int capacity = seatRs.getInt("capacity");
      int booked = seatRs.getInt("booked");

      if (booked >= capacity) {
        // Flight is full -> redirect to waitlist
        response.sendRedirect("handleWaitlist.jsp?flight_id=" + flightId +
                      "&airline_id=" + airlineId +
                      "&class=" + seatClass +
                      "&reason=full");
        return;
      }
    }
    

    // Generate ticket ID using UUID
    String ticketId = "T-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

    // Insert into ticket
    PreparedStatement ticketStmt = con.prepareStatement(
      "INSERT INTO ticket (Ticket_ID, First_Name, Last_Name, Status, Seat_Number, Total_Fare, Purchase_DateTime, Booking_Fee, Class, uid) " +
      "VALUES (?, ?, ?, 'Confirmed', NULL, 500.00, NOW(), 20.00, ?, ?)"
    );
    ticketStmt.setString(1, ticketId);
    ticketStmt.setString(2, fname);
    ticketStmt.setString(3, lname);
    ticketStmt.setString(4, seatClass);
    ticketStmt.setInt(5, uid);
    ticketStmt.executeUpdate();

    // Link ticket to flight
    PreparedStatement assocStmt = con.prepareStatement(
      "INSERT INTO associated_with_ticketflight (flight_id, Ticket_ID, airline_id) VALUES (?, ?, ?)"
    );
    assocStmt.setString(1, flightId);
    assocStmt.setString(2, ticketId);
    assocStmt.setString(3, airlineId);
    assocStmt.executeUpdate();

    out.println("<p style='color:green;'>Booking confirmed! Your ticket ID is: <strong>" + ticketId + "</strong></p>");

    con.close();
  } catch (Exception e) {
    out.println("<p style='color:red;'>Booking failed: " + e.getMessage() + "</p>");
  }
%>
