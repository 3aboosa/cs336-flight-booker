<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*,java.sql.*,java.util.*" %>
<%
    // Prevent caching
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Authentication and role check (assumes "role" session attribute)
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("customerrepresentative")) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Handle form submissions
    String action = request.getParameter("action");
    String message = null;
    try {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();

        if ("makeReservation".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO ticket (Ticket_ID, First_Name, Last_Name, Status, Seat_Number, Total_Fare, Purchase_DateTime, Booking_Fee, Class, uid) " +
                "VALUES (?, ?, ?, ?, ?, ?, NOW(), ?, ?, ?)"
            );
            ps.setString(1, request.getParameter("ticketId"));
            ps.setString(2, request.getParameter("firstName"));
            ps.setString(3, request.getParameter("lastName"));
            ps.setString(4, "Booked");
            ps.setString(5, request.getParameter("seatNumber"));
            ps.setBigDecimal(6, new java.math.BigDecimal(request.getParameter("totalFare")));
            ps.setBigDecimal(7, new java.math.BigDecimal(request.getParameter("bookingFee")));
            ps.setString(8, request.getParameter("class"));
            ps.setString(9, request.getParameter("uid"));
            ps.executeUpdate();
            message = "Reservation created.";
            ps.close();
        } else if ("editReservation".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "UPDATE ticket SET Status=?, Seat_Number=? WHERE Ticket_ID=?"
            );
            ps.setString(1, request.getParameter("status"));
            ps.setString(2, request.getParameter("seatNumber"));
            ps.setString(3, request.getParameter("ticketId"));
            ps.executeUpdate();
            message = "Reservation updated.";
            ps.close();

        } else if ("addAircraft".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO aircraft (aircraft_id, airline_id, number_of_seats, model) VALUES (?, ?, ?, ?)"
            );
            ps.setString(1, request.getParameter("aircraftId"));
            ps.setString(2, request.getParameter("airlineId"));
            ps.setInt(3, Integer.parseInt(request.getParameter("seats")));
            ps.setString(4, request.getParameter("model"));
            ps.executeUpdate();
            message = "Aircraft added.";
            ps.close();
        } else if ("editAircraft".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "UPDATE aircraft SET airline_id=?, number_of_seats=?, model=? WHERE aircraft_id=?"
            );
            ps.setString(1, request.getParameter("airlineId"));
            ps.setInt(2, Integer.parseInt(request.getParameter("seats")));
            ps.setString(3, request.getParameter("model"));
            ps.setString(4, request.getParameter("aircraftId"));
            ps.executeUpdate();
            message = "Aircraft updated.";
            ps.close();
        } else if ("deleteAircraft".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "DELETE FROM aircraft WHERE aircraft_id=?"
            );
            ps.setString(1, request.getParameter("aircraftId"));
            ps.executeUpdate();
            message = "Aircraft deleted.";
            ps.close();

        } else if ("addAirport".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO airport (airport_id, city, country, name) VALUES (?, ?, ?, ?)"
            );
            ps.setString(1, request.getParameter("airportId"));
            ps.setString(2, request.getParameter("city"));
            ps.setString(3, request.getParameter("country"));
            ps.setString(4, request.getParameter("name"));
            ps.executeUpdate();
            message = "Airport added.";
            ps.close();
        } else if ("editAirport".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "UPDATE airport SET city=?, country=?, name=? WHERE airport_id=?"
            );
            ps.setString(1, request.getParameter("city"));
            ps.setString(2, request.getParameter("country"));
            ps.setString(3, request.getParameter("name"));
            ps.setString(4, request.getParameter("airportId"));
            ps.executeUpdate();
            message = "Airport updated.";
            ps.close();
        } else if ("deleteAirport".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "DELETE FROM airport WHERE airport_id=?"
            );
            ps.setString(1, request.getParameter("airportId"));
            ps.executeUpdate();
            message = "Airport deleted.";
            ps.close();

        } else if ("addFlight".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO flights (flight_id, is_Domestic, days_of_operation, arrival_airport_id, departure_airport_id, arrival_time, departure_time, aircraft_id, airline_id, number_of_stops, price) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
            );
            ps.setString(1, request.getParameter("flightId"));
            ps.setInt(2, Integer.parseInt(request.getParameter("isDomestic")));
            ps.setString(3, request.getParameter("daysOp"));
            ps.setString(4, request.getParameter("arrivalId"));
            ps.setString(5, request.getParameter("departureId"));
            ps.setTimestamp(6, Timestamp.valueOf(request.getParameter("arrivalTime")));
            ps.setTimestamp(7, Timestamp.valueOf(request.getParameter("departureTime")));
            ps.setString(8, request.getParameter("aircraftId"));
            ps.setString(9, request.getParameter("airlineId"));
            ps.setInt(10,Integer.parseInt(request.getParameter("stops")));
            ps.setBigDecimal(11,new java.math.BigDecimal(request.getParameter("price")));
            ps.executeUpdate();
            message = "Flight added.";
            ps.close();
        } else if ("editFlight".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "UPDATE flights SET is_Domestic=?, days_of_operation=?, arrival_airport_id=?, departure_airport_id=?, arrival_time=?, departure_time=?, aircraft_id=?, airline_id=?, number_of_stops=?, price=? WHERE flight_id=?"
            );
            ps.setInt(1,Integer.parseInt(request.getParameter("isDomestic")));
            ps.setString(2,request.getParameter("daysOp"));
            ps.setString(3,request.getParameter("arrivalId"));
            ps.setString(4,request.getParameter("departureId"));
            ps.setTimestamp(5,Timestamp.valueOf(request.getParameter("arrivalTime")));
            ps.setTimestamp(6,Timestamp.valueOf(request.getParameter("departureTime")));
            ps.setString(7,request.getParameter("aircraftId"));
            ps.setString(8,request.getParameter("airlineId"));
            ps.setInt(9,Integer.parseInt(request.getParameter("stops")));
            ps.setBigDecimal(10,new java.math.BigDecimal(request.getParameter("price")));
            ps.setString(11,request.getParameter("flightId"));
            ps.executeUpdate();
            message = "Flight updated.";
            ps.close();
        } else if ("deleteFlight".equals(action)) {
            PreparedStatement ps = con.prepareStatement("DELETE FROM flights WHERE flight_id=?");
            ps.setString(1, request.getParameter("flightId"));
            ps.executeUpdate();
            message = "Flight deleted.";
            ps.close();

        } else if ("waitingList".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "SELECT t.Ticket_ID, t.First_Name, t.Last_Name " +
                "FROM ticket t JOIN flight_waitlist w ON t.Ticket_ID=w.Ticket_ID " +
                "WHERE w.flight_id=?"
            );
            ps.setString(1, request.getParameter("flightIdW"));
            ResultSet rs = ps.executeQuery();
            request.setAttribute("waitingRs", rs);
            // rs will be closed after display
        } else if ("listFlights".equals(action)) {
            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM flights WHERE departure_airport_id=? OR arrival_airport_id=?"
            );
            ps.setString(1, request.getParameter("airportId"));
            ps.setString(2, request.getParameter("airportId"));
            ResultSet rs = ps.executeQuery();
            request.setAttribute("flightsRs", rs);
        }

        con.close();
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html>
<head><title>Customer Rep Dashboard</title>
  <style> body{font-family:Arial,sans-serif;margin:1em;} .section{border:1px solid #ccc;padding:1em;margin-bottom:1em;} .section h2{margin-top:0;} label{display:inline-block;width:120px;}</style>
</head>
<body>
  <h1>Customer Rep Dashboard</h1>
  <%= (message!=null?"<p><strong>"+message+"</strong></p>":"") %>
  <div class="section">
    <h2>Make Reservation</h2>
    <form method="post">
      <input type="hidden" name="action" value="makeReservation"/>
      <label>Ticket ID:</label><input name="ticketId"/><br/>
      <label>First Name:</label><input name="firstName"/><br/>
      <label>Last Name:</label><input name="lastName"/><br/>
      <label>Seat Number:</label><input name="seatNumber"/><br/>
      <label>Total Fare:</label><input name="totalFare"/><br/>
      <label>Booking Fee:</label><input name="bookingFee"/><br/>
      <label>Class:</label><input name="class"/><br/>
      <label>User ID:</label><input name="uid"/><br/>
      <button type="submit">Create</button>
    </form>
  </div>
  <div class="section">
    <h2>Edit Reservation</h2>
    <form method="post">
      <input type="hidden" name="action" value="editReservation"/>
      <label>Ticket ID:</label><input name="ticketId"/><br/>
      <label>Status:</label><input name="status"/><br/>
      <label>Seat Number:</label><input name="seatNumber"/><br/>
      <button type="submit">Update</button>
    </form>
  </div>
  <div class="section">
    <h2>Manage Aircraft</h2>
    <form method="post" style="margin-bottom:0.5em;">
      <input type="hidden" name="action" value="addAircraft"/>
      <label>ID:</label><input name="aircraftId"/><br/>
      <label>Airline:</label><input name="airlineId"/><br/>
      <label>Seats:</label><input name="seats"/><br/>
      <label>Model:</label><input name="model"/><br/>
      <button type="submit">Add</button>
    </form>
    <form method="post" style="margin-bottom:0.5em;">
      <input type="hidden" name="action" value="editAircraft"/>
      <label>ID:</label><input name="aircraftId"/><br/>
      <label>Airline:</label><input name="airlineId"/><br/>
      <label>Seats:</label><input name="seats"/><br/>
      <label>Model:</label><input name="model"/><br/>
      <button type="submit">Edit</button>
    </form>
    <form method="post">
      <input type="hidden" name="action`
