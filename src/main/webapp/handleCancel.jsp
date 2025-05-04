<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
  String ticketId = request.getParameter("ticket_id");

  if (ticketId == null || ticketId.trim().equals("")) {
    out.println("<p style='color:red;'>Missing ticket ID.</p>");
    return;
  }

  try {
    ApplicationDB db = new ApplicationDB();	
    Connection con = db.getConnection();

    // Step 1: Get flight_id and airline_id from associated_with_ticketflight
    PreparedStatement flightStmt = con.prepareStatement(
      "SELECT flight_id, airline_id FROM associated_with_ticketflight WHERE Ticket_ID = ?"
    );
    flightStmt.setString(1, ticketId);
    ResultSet flightRs = flightStmt.executeQuery();

    String flightId = null;
    String airlineId = null;
    if (flightRs.next()) {
      flightId = flightRs.getString("flight_id");
      airlineId = flightRs.getString("airline_id");
    }

    // Step 2: Delete from associated_with_ticketflight
    PreparedStatement deleteAssoc = con.prepareStatement(
      "DELETE FROM associated_with_ticketflight WHERE Ticket_ID = ?"
    );
    deleteAssoc.setString(1, ticketId);
    deleteAssoc.executeUpdate();

    // Step 3: Delete from ticket
    PreparedStatement deleteTicket = con.prepareStatement(
      "DELETE FROM ticket WHERE Ticket_ID = ?"
    );
    deleteTicket.setString(1, ticketId);
    deleteTicket.executeUpdate();

    // Step 4: Promote a waitlisted ticket (if any)
    if (flightId != null && airlineId != null) {
      PreparedStatement promoteStmt = con.prepareStatement(
        "SELECT t.Ticket_ID FROM ticket t " +
        "JOIN associated_with_ticketflight a ON t.Ticket_ID = a.Ticket_ID " +
        "WHERE t.Status = 'Waitlisted' AND a.flight_id = ? AND a.airline_id = ? " +
        "ORDER BY t.Purchase_DateTime ASC LIMIT 1"
      );
      promoteStmt.setString(1, flightId);
      promoteStmt.setString(2, airlineId);
      ResultSet promoteRs = promoteStmt.executeQuery();

      if (promoteRs.next()) {
        String promoteId = promoteRs.getString("Ticket_ID");

        PreparedStatement updateStatus = con.prepareStatement(
          "UPDATE ticket SET Status = 'Confirmed' WHERE Ticket_ID = ?"
        );
        updateStatus.setString(1, promoteId);
        updateStatus.executeUpdate();

        PreparedStatement setFlag = con.prepareStatement(
   		  "UPDATE ticket SET promoted_flag = TRUE WHERE Ticket_ID = ?"
   		);
   		setFlag.setString(1, promoteId);
   		setFlag.executeUpdate();
   		setFlag.close();

      }

      promoteRs.close();
      promoteStmt.close();
    }

    con.close();
    response.sendRedirect("myFlights.jsp");

  } catch (Exception e) {
    out.println("<p style='color:red;'>Error cancelling ticket: " + e.getMessage() + "</p>");
  }
%>
