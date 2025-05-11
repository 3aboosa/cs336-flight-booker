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
  
  if (session.getAttribute("alertPromoted") != null) {
	    String promotedTicket = (String) session.getAttribute("alertPromoted");
    %>
    <p style="color: green; font-weight: bold;">
      Good news! A seat opened up and your waitlisted ticket <%= promotedTicket %> has been confirmed.
    </p>
<%
    session.removeAttribute("alertPromoted");
  }
  String username = (String) session.getAttribute("username");
  int uid = -1;

  try {
    ApplicationDB db = new ApplicationDB();	
    Connection con = db.getConnection();

    PreparedStatement getUid = con.prepareStatement("SELECT uid FROM individual WHERE username = ?");
    getUid.setString(1, username);
    ResultSet uidRs = getUid.executeQuery();
    if (uidRs.next()) {
      uid = uidRs.getInt("uid");
    }
    PreparedStatement flagCheck = con.prepareStatement(
	  "SELECT Ticket_ID FROM ticket WHERE uid = ? AND promoted_flag = TRUE"
	);
	flagCheck.setInt(1, uid);
	ResultSet flagRs = flagCheck.executeQuery();

	if (flagRs.next()) {
	  out.println("<p style='color: green; font-weight: bold;'>A seat opened up,  your waitlisted ticket has been confirmed!</p>");
	  
	  // Clear the flag
	  PreparedStatement clearFlag = con.prepareStatement(
	    "UPDATE ticket SET promoted_flag = FALSE WHERE Ticket_ID = ?"
	  );
	  clearFlag.setString(1, flagRs.getString("Ticket_ID"));
	  clearFlag.executeUpdate();
	  clearFlag.close();
	}

	flagRs.close();
	flagCheck.close();


    PreparedStatement flightStmt = con.prepareStatement(
      "SELECT f.flight_id, f.departure_airport_id, f.arrival_airport_id, f.departure_time, f.arrival_time, t.Ticket_ID, t.Status, t.Class " +
      "FROM ticket t " +
      "JOIN associated_with_ticketflight a ON t.Ticket_ID = a.Ticket_ID " +
      "JOIN flights f ON a.flight_id = f.flight_id AND a.airline_id = f.airline_id " +
      "WHERE t.uid = ? " +
      "ORDER BY f.departure_time DESC"
    );
    flightStmt.setInt(1, uid);
    ResultSet rs = flightStmt.executeQuery();
%>

<html>
	<head>
		<title>My Flights</title>
	</head>
	<body>
		<h2>My Flights</h2>
		
		<form method="get" style="margin-bottom: 20px;">
		  <label for="filter">Show:</label>
		  <select name="filter" id="filter" onchange="this.form.submit()">
		    <option value="all" <%= "all".equals(request.getParameter("filter")) ? "selected" : "" %>>All</option>
		    <option value="upcoming" <%= "upcoming".equals(request.getParameter("filter")) ? "selected" : "" %>>Upcoming</option>
		    <option value="past" <%= "past".equals(request.getParameter("filter")) ? "selected" : "" %>>Past</option>
		    <option value="waitlisted" <%= "waitlisted".equals(request.getParameter("filter")) ? "selected" : "" %>>Waitlisted</option>
		  </select>
		</form>
		
		<table border="1" cellpadding="5">
		  <tr>
		    <th>Ticket ID</th>
		    <th>Flight</th>
		    <th>Departure</th>
		    <th>Arrival</th>
		    <th>Class</th>
		    <th>Status</th>
		    <th>Type</th>
		  </tr>
		
		<%
		    while (rs.next()) {
		      String ticketId = rs.getString("Ticket_ID");
		      String flight = rs.getString("flight_id");
		      String dep = rs.getString("departure_airport_id");
		      String arr = rs.getString("arrival_airport_id");
		      String depTime = rs.getString("departure_time");
		      String arrTime = rs.getString("arrival_time");
		      String status = rs.getString("Status");
		      String seatClass = rs.getString("Class");
		
		      Timestamp arrivalTimestamp = Timestamp.valueOf(rs.getString("arrival_time"));
		      boolean isPast = arrivalTimestamp.before(new java.util.Date());
		      boolean isUpcoming = !isPast;
		      String filter = request.getParameter("filter");
		      if (filter == null) filter = "all";

		      boolean show = "all".equals(filter) ||
		                     ("upcoming".equals(filter) && "Confirmed".equals(status) && isUpcoming) ||
		                     ("past".equals(filter) && "Confirmed".equals(status) && isPast) ||
		                     ("waitlisted".equals(filter) && "Waitlisted".equals(status));

		      boolean canCancel = "Confirmed".equals(status) &&
	                    isUpcoming &&
	                    ("Business".equalsIgnoreCase(seatClass) || "First".equalsIgnoreCase(seatClass));

		      if (!show) continue;

		%>
		  <tr>
		    <td><%= ticketId %></td>
		    <td><%= flight %> (<%= dep %> -> <%= arr %>)</td>
		    <td><%= depTime %></td>
		    <td><%= arrTime %></td>
		    <td><%= seatClass %></td>
		    <td><%= status %></td>
		    <td><%= isPast ? "Past" : "Upcoming" %></td>
		    <td>
			  <% if (canCancel) { %>
			    <form action="handleCancel.jsp" method="post" style="margin: 0;">
			      <input type="hidden" name="ticket_id" value="<%= ticketId %>" />
			      <button type="submit" onclick="return confirm('Are you sure you want to cancel this reservation?');">Cancel</button>
			    </form>
			  <% } else { %>
			    N/A
			  <% } %>
			</td>
		    
		  </tr>
		<%
		    }
		
		    con.close();
		  } catch (Exception e) {
		    out.println("<p style='color:red;'>Error loading flights: " + e.getMessage() + "</p>");
		  }
		%>
		</table>
	
	</body>
</html>