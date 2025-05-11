<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="com.cs336.pkg.*,java.sql.*,java.util.*" %>
<%
    // Prevent caching
    response.setHeader("Cache-Control","no-cache,no-store,must-revalidate");
    response.setHeader("Pragma","no-cache");
    response.setDateHeader("Expires", 0);

    // Auth & role
    String role = (String)session.getAttribute("role");
    if (role == null || !role.equals("customerrepresentative")) {
        response.sendRedirect("login.jsp");
        return;
    }

    String action  = request.getParameter("action");
    String message = null;

    Map<String,Object> airportMap   = null,
                      aircraftMap  = null,
                      flightMap    = null,
                      ticketMap    = null;
    List<Map<String,Object>> flightsForAirport = null;

    // load airlines for dropdown
    List<Map<String,String>> airlineList = new ArrayList<>();
    try (Connection con = new ApplicationDB().getConnection()) {
        // load airlines
        try (PreparedStatement ps = con.prepareStatement("SELECT airline_id, Name FROM airline");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,String> a = new HashMap<>();
                a.put("id",   rs.getString("airline_id"));
                a.put("name", rs.getString("Name"));
                airlineList.add(a);
            }
        }

        // --- AIRPORT ---
        if ("addAirport".equals(action)) {
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO airport(airport_id,city,country,name) VALUES(?,?,?,?)")) {
                ps.setString(1, request.getParameter("airportId"));
                ps.setString(2, request.getParameter("city"));
                ps.setString(3, request.getParameter("country"));
                ps.setString(4, request.getParameter("airportName"));
                ps.executeUpdate();
            }
            message = "Airport added.";

        } else if ("deleteAirport".equals(action)) {
            String aid = request.getParameter("airportId");
            try (PreparedStatement pd1 = con.prepareStatement(
                    "DELETE FROM flights WHERE arrival_airport_id=? OR departure_airport_id=?")) {
                pd1.setString(1, aid);
                pd1.setString(2, aid);
                pd1.executeUpdate();
            }
            try (PreparedStatement pd2 = con.prepareStatement(
                    "DELETE FROM associated_with_airportairline WHERE airport_id=?")) {
                pd2.setString(1, aid);
                pd2.executeUpdate();
            }
            try (PreparedStatement pd3 = con.prepareStatement(
                    "DELETE FROM airport WHERE airport_id=?")) {
                pd3.setString(1, aid);
                pd3.executeUpdate();
            }
            message = "Airport & related rows deleted.";

        } else if ("searchAirport".equals(action)) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT * FROM airport WHERE airport_id=?")) {
                ps.setString(1, request.getParameter("searchAirportId"));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        airportMap = new HashMap<>();
                        airportMap.put("airport_id", rs.getString("airport_id"));
                        airportMap.put("city",       rs.getString("city"));
                        airportMap.put("country",    rs.getString("country"));
                        airportMap.put("name",       rs.getString("name"));
                    } else {
                        message = "Airport not found.";
                    }
                }
            }

        } else if ("editAirport".equals(action)) {
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE airport SET city=?,country=?,name=? WHERE airport_id=?")) {
                ps.setString(1, request.getParameter("city"));
                ps.setString(2, request.getParameter("country"));
                ps.setString(3, request.getParameter("airportName"));
                ps.setString(4, request.getParameter("airportId"));
                ps.executeUpdate();
            }
            message = "Airport updated.";

        // --- AIRCRAFT ---
        } else if ("addAircraft".equals(action)) {
            String aidParam = request.getParameter("airlineId");
            try (PreparedStatement chk = con.prepareStatement(
                    "SELECT 1 FROM airline WHERE airline_id=?")) {
                chk.setString(1, aidParam);
                try (ResultSet chkRs = chk.executeQuery()) {
                    if (!chkRs.next()) {
                        message = "Cannot add aircraft: Airline ID '" + aidParam + "' does not exist.";
                    } else {
                        try (PreparedStatement ps = con.prepareStatement(
                                "INSERT INTO aircraft(aircraft_id,airline_id,number_of_seats,model) VALUES(?,?,?,?)")) {
                            ps.setString(1, request.getParameter("aircraftId"));
                            ps.setString(2, aidParam);
                            ps.setInt(3, Integer.parseInt(request.getParameter("seats")));
                            ps.setString(4, request.getParameter("model"));
                            ps.executeUpdate();
                        }
                        message = "Aircraft added.";
                    }
                }
            }

        } else if ("deleteAircraft".equals(action)) {
            String ac = request.getParameter("aircraftId");
            try (PreparedStatement pd = con.prepareStatement(
                    "DELETE FROM flights WHERE aircraft_id=?")) {
                pd.setString(1, ac);
                pd.executeUpdate();
            }
            try (PreparedStatement pd2 = con.prepareStatement(
                    "DELETE FROM aircraft WHERE aircraft_id=?")) {
                pd2.setString(1, ac);
                pd2.executeUpdate();
            }
            message = "Aircraft & related flights deleted.";

        } else if ("searchAircraft".equals(action)) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT * FROM aircraft WHERE aircraft_id=?")) {
                ps.setString(1, request.getParameter("searchAircraftId"));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        aircraftMap = new HashMap<>();
                        aircraftMap.put("aircraft_id",     rs.getString("aircraft_id"));
                        aircraftMap.put("airline_id",      rs.getString("airline_id"));
                        aircraftMap.put("number_of_seats", rs.getString("number_of_seats"));
                        aircraftMap.put("model",           rs.getString("model"));
                    } else {
                        message = "Aircraft not found.";
                    }
                }
            }

        } else if ("editAircraft".equals(action)) {
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE aircraft SET airline_id=?,number_of_seats=?,model=? WHERE aircraft_id=?")) {
                ps.setString(1, request.getParameter("airlineId"));
                ps.setInt(2, Integer.parseInt(request.getParameter("seats")));
                ps.setString(3, request.getParameter("model"));
                ps.setString(4, request.getParameter("aircraftId"));
                ps.executeUpdate();
            }
            message = "Aircraft updated.";

        // --- FLIGHT ---
        } else if ("addFlight".equals(action)) {
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO flights(" +
                    "flight_id,is_Domestic,days_of_operation," +
                    "arrival_airport_id,departure_airport_id," +
                    "arrival_time,departure_time,aircraft_id,airline_id,number_of_stops,price)" +
                    " VALUES(?,?,?,?,?,?,?,?,?,?,?)")) {
                ps.setString(1, request.getParameter("flightId"));
                ps.setInt(2, Integer.parseInt(request.getParameter("isDomestic")));
                ps.setString(3, request.getParameter("daysOp"));
                ps.setString(4, request.getParameter("arrivalId"));
                ps.setString(5, request.getParameter("departureId"));
                ps.setTimestamp(6, Timestamp.valueOf(request.getParameter("arrivalTime")));
                ps.setTimestamp(7, Timestamp.valueOf(request.getParameter("departureTime")));
                ps.setString(8, request.getParameter("aircraftId"));
                ps.setString(9, request.getParameter("airlineId"));
                ps.setInt(10, Integer.parseInt(request.getParameter("stops")));
                ps.setBigDecimal(11, new java.math.BigDecimal(request.getParameter("price")));
                ps.executeUpdate();
            }
            message = "Flight added.";

        } else if ("deleteFlight".equals(action)) {
            String fid = request.getParameter("flightId");
            try (PreparedStatement pd = con.prepareStatement(
                    "DELETE FROM flights WHERE flight_id=?")) {
                pd.setString(1, fid);
                pd.executeUpdate();
            }
            message = "Flight deleted.";

        } else if ("searchFlight".equals(action)) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT *, TIMESTAMPDIFF(MINUTE,departure_time,arrival_time) AS dur " +
                    "FROM flights WHERE flight_id=?")) {
                ps.setString(1, request.getParameter("searchFlightId"));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        flightMap = new HashMap<>();
                        flightMap.put("flight_id",            rs.getString("flight_id"));
                        flightMap.put("is_Domestic",          rs.getString("is_Domestic"));
                        flightMap.put("days_of_operation",    rs.getString("days_of_operation"));
                        flightMap.put("departure_airport_id", rs.getString("departure_airport_id"));
                        flightMap.put("arrival_airport_id",   rs.getString("arrival_airport_id"));
                        flightMap.put("departure_time",       rs.getString("departure_time"));
                        flightMap.put("arrival_time",         rs.getString("arrival_time"));
                        flightMap.put("aircraft_id",          rs.getString("aircraft_id"));
                        flightMap.put("airline_id",           rs.getString("airline_id"));
                        flightMap.put("number_of_stops",      rs.getString("number_of_stops"));
                        flightMap.put("price",                rs.getString("price"));
                        flightMap.put("duration",             rs.getString("dur"));
                    } else {
                        message = "Flight not found.";
                    }
                }
            }

        } else if ("editFlight".equals(action)) {
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE flights SET " +
                    "is_Domestic=?,days_of_operation=?,arrival_airport_id=?,departure_airport_id=?,arrival_time=?,departure_time=?,aircraft_id=?,airline_id=?,number_of_stops=?,price=? " +
                    "WHERE flight_id=?")) {
                ps.setInt(1, Integer.parseInt(request.getParameter("isDomestic")));
                ps.setString(2, request.getParameter("daysOp"));
                ps.setString(3, request.getParameter("arrivalId"));
                ps.setString(4, request.getParameter("departureId"));
                ps.setTimestamp(5, Timestamp.valueOf(request.getParameter("arrivalTime")));
                ps.setTimestamp(6, Timestamp.valueOf(request.getParameter("departureTime")));
                ps.setString(7, request.getParameter("aircraftId"));
                ps.setString(8, request.getParameter("airlineId"));
                ps.setInt(9, Integer.parseInt(request.getParameter("stops")));
                ps.setBigDecimal(10, new java.math.BigDecimal(request.getParameter("price")));
                ps.setString(11, request.getParameter("flightId"));
                ps.executeUpdate();
            }
            message = "Flight updated.";

        // --- TICKET ---
        } else if ("addTicket".equals(action)) {
            int uidInt = Integer.parseInt(request.getParameter("uid"));
            boolean createdIndividual = false;
            boolean createdCustomer   = false;

            // ensure individual exists
            try (PreparedStatement chkInd = con.prepareStatement(
                    "SELECT 1 FROM individual WHERE uid=?")) {
                chkInd.setInt(1, uidInt);
                try (ResultSet rs = chkInd.executeQuery()) {
                    if (!rs.next()) {
                        try (PreparedStatement insInd = con.prepareStatement(
                                "INSERT INTO individual(uid) VALUES(?)")) {
                            insInd.setInt(1, uidInt);
                            insInd.executeUpdate();
                        }
                        createdIndividual = true;
                    }
                }
            }

            // ensure customer exists
            try (PreparedStatement chkCust = con.prepareStatement(
                    "SELECT 1 FROM customer WHERE uid=?")) {
                chkCust.setInt(1, uidInt);
                try (ResultSet rs = chkCust.executeQuery()) {
                    if (!rs.next()) {
                        try (PreparedStatement insCust = con.prepareStatement(
                                "INSERT INTO customer(uid) VALUES(?)")) {
                            insCust.setInt(1, uidInt);
                            insCust.executeUpdate();
                        }
                        createdCustomer = true;
                    }
                }
            }

            // insert ticket
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO ticket(" +
                    "Ticket_ID,First_Name,Last_Name,Status,Seat_Number,Total_Fare," +
                    "Purchase_DateTime,Booking_Fee,Class,uid,promoted_flag) " +
                    "VALUES(?,?,?,?,?,?,?,?,?,?,?)")) {
                ps.setString(1, request.getParameter("ticketId"));
                ps.setString(2, request.getParameter("firstName"));
                ps.setString(3, request.getParameter("lastName"));
                ps.setString(4, request.getParameter("status"));
                ps.setString(5, request.getParameter("seatNumber"));
                ps.setDouble(6, Double.parseDouble(request.getParameter("totalFare")));
                ps.setTimestamp(7, Timestamp.valueOf(request.getParameter("purchaseDateTime")));
                ps.setDouble(8, Double.parseDouble(request.getParameter("bookingFee")));
                ps.setString(9, request.getParameter("ticketClass"));
                ps.setInt(10, uidInt);
                ps.setInt(11, Integer.parseInt(request.getParameter("promotedFlag")));
                ps.executeUpdate();
            }

            StringBuilder sb = new StringBuilder();
            if (createdIndividual) sb.append("New individual created. ");
            if (createdCustomer)   sb.append("New customer created. ");
            sb.append("Ticket added.");
            message = sb.toString();

        } else if ("searchTicket".equals(action)) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT * FROM ticket WHERE Ticket_ID=?")) {
                ps.setString(1, request.getParameter("searchTicketId"));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        ticketMap = new HashMap<>();
                        ticketMap.put("Ticket_ID",         rs.getString("Ticket_ID"));
                        ticketMap.put("First_Name",        rs.getString("First_Name"));
                        ticketMap.put("Last_Name",         rs.getString("Last_Name"));
                        ticketMap.put("Status",            rs.getString("Status"));
                        ticketMap.put("Seat_Number",       rs.getString("Seat_Number"));
                        ticketMap.put("Total_Fare",        rs.getString("Total_Fare"));
                        ticketMap.put("Purchase_DateTime", rs.getString("Purchase_DateTime"));
                        ticketMap.put("Booking_Fee",       rs.getString("Booking_Fee"));
                        ticketMap.put("Class",             rs.getString("Class"));
                        ticketMap.put("uid",               rs.getString("uid"));
                        ticketMap.put("promoted_flag",     rs.getString("promoted_flag"));
                    } else {
                        message = "Ticket not found.";
                    }
                }
            }

        } else if ("editTicket".equals(action)) {
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE ticket SET First_Name=?,Last_Name=?,Status=?,Seat_Number=?,Total_Fare=?," +
                    "Purchase_DateTime=?,Booking_Fee=?,Class=?,uid=?,promoted_flag=? WHERE Ticket_ID=?")) {
                ps.setString(1, request.getParameter("firstName"));
                ps.setString(2, request.getParameter("lastName"));
                ps.setString(3, request.getParameter("status"));
                ps.setString(4, request.getParameter("seatNumber"));
                ps.setDouble(5, Double.parseDouble(request.getParameter("totalFare")));
                ps.setTimestamp(6, Timestamp.valueOf(request.getParameter("purchaseDateTime")));
                ps.setDouble(7, Double.parseDouble(request.getParameter("bookingFee")));
                ps.setString(8, request.getParameter("ticketClass"));
                ps.setInt(9, Integer.parseInt(request.getParameter("uid")));
                ps.setInt(10, Integer.parseInt(request.getParameter("promotedFlag")));
                ps.setString(11, request.getParameter("ticketId"));
                ps.executeUpdate();
            }
            message = "Ticket updated.";

        // --- LIST FLIGHTS BY AIRPORT ---
        } else if ("listFlights".equals(action)) {
            String aid = request.getParameter("listAirportId");
            flightsForAirport = new ArrayList<>();
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT * FROM flights WHERE departure_airport_id=? OR arrival_airport_id=?")) {
                ps.setString(1, aid);
                ps.setString(2, aid);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String,Object> m = new HashMap<>();
                        m.put("flight_id",             rs.getString("flight_id"));
                        m.put("is_Domestic",           rs.getInt("is_Domestic"));
                        m.put("days_of_operation",     rs.getString("days_of_operation"));
                        m.put("departure_airport_id",  rs.getString("departure_airport_id"));
                        m.put("arrival_airport_id",    rs.getString("arrival_airport_id"));
                        m.put("departure_time",        rs.getTimestamp("departure_time"));
                        m.put("arrival_time",          rs.getTimestamp("arrival_time"));
                        m.put("aircraft_id",           rs.getString("aircraft_id"));
                        m.put("airline_id",            rs.getString("airline_id"));
                        m.put("number_of_stops",       rs.getInt("number_of_stops"));
                        m.put("price",                 rs.getBigDecimal("price"));
                        flightsForAirport.add(m);
                    }
                }
            }
            message = "Found " + flightsForAirport.size() + " flights for airport " + aid + ".";

        }

    } catch (Exception e) {
        message = "Error: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Customer Rep Dashboard</title>
  <style>
    body{font-family:Arial,sans-serif;margin:1em;}
    .section{border:1px solid #ccc;padding:1em;margin-bottom:1em;}
    .section h2{margin-top:0;}
    .split{display:flex;}
    .split>div{flex:1;padding:0 1em;}
    .split>div:first-child{border-right:1px solid #ccc;}
    label{display:block;margin:0.5em 0 0.2em;}
    input,select,button{width:100%;padding:0.3em;box-sizing:border-box;margin-bottom:0.5em;}
    table{width:100%;border-collapse:collapse;margin-top:0.5em;}
    th,td{border:1px solid #ddd;padding:8px;text-align:left;}
  </style>
</head>
<body>
  <h1>Customer Rep Dashboard</h1>
  <%= message!=null ? "<p><strong>"+message+"</strong></p>" : "" %>

  <!-- Manage Airport -->
  <div class="section">
    <h2>Manage Airport</h2>
    <div class="split">
      <div>
        <form method="post">
          <input type="hidden" name="action" value="addAirport"/>
          <label>Airport ID:</label><input name="airportId"/>
          <label>City:</label><input name="city"/>
          <label>Country:</label><input name="country"/>
          <label>Name:</label><input name="airportName"/>
          <button type="submit">Add Airport</button>
        </form>
        <form method="post">
          <input type="hidden" name="action" value="deleteAirport"/>
          <label>Airport ID to Delete:</label><input name="airportId"/>
          <button type="submit">Delete Airport</button>
        </form>
        <form method="post">
          <input type="hidden" name="action" value="searchAirport"/>
          <label>Search Airport ID:</label><input name="searchAirportId"/>
          <button type="submit">Search Airport</button>
        </form>
        <% if (airportMap!=null) { %>
        <table>
          <tr><th>Field</th><th>Value</th></tr>
          <tr><td>airport_id</td><td><%=airportMap.get("airport_id")%></td></tr>
          <tr><td>city</td><td><%=airportMap.get("city")%></td></tr>
          <tr><td>country</td><td><%=airportMap.get("country")%></td></tr>
          <tr><td>name</td><td><%=airportMap.get("name")%></td></tr>
        </table>
        <% } %>
      </div>
      <div>
        <% if (airportMap!=null) { %>
        <form method="post">
          <input type="hidden" name="action" value="editAirport"/>
          <input type="hidden" name="airportId" value="<%=airportMap.get("airport_id")%>"/>
          <label>City:</label><input name="city" value="<%=airportMap.get("city")%>"/>
          <label>Country:</label><input name="country" value="<%=airportMap.get("country")%>"/>
          <label>Name:</label><input name="airportName" value="<%=airportMap.get("name")%>"/>
          <button type="submit">Update Airport</button>
        </form>
        <% } else { %>
          <em>Search an Airport to edit.</em>
        <% } %>
      </div>
    </div>
  </div>

  <!-- Manage Aircraft -->
  <div class="section">
    <h2>Manage Aircraft</h2>
    <div class="split">
      <div>
        <form method="post">
          <input type="hidden" name="action" value="addAircraft"/>
          <label>Aircraft ID:</label><input name="aircraftId"/>
          <label>Airline:</label>
          <select name="airlineId">
            <option value="">-- select airline --</option>
            <% for (Map<String,String> a: airlineList) { %>
              <option value="<%=a.get("id")%>"><%=a.get("id")%> – <%=a.get("name")%></option>
            <% } %>
          </select>
          <label>Seats:</label><input name="seats"/>
          <label>Model:</label><input name="model"/>
          <button type="submit">Add Aircraft</button>
        </form>
        <form method="post">
          <input type="hidden" name="action" value="deleteAircraft"/>
          <label>Aircraft ID to Delete:</label><input name="aircraftId"/>
          <button type="submit">Delete Aircraft</button>
        </form>
        <form method="post">
          <input type="hidden" name="action" value="searchAircraft"/>
          <label>Search Aircraft ID:</label><input name="searchAircraftId"/>
          <button type="submit">Search Aircraft</button>
        </form>
        <% if (aircraftMap!=null) { %>
        <table>
          <tr><th>Field</th><th>Value</th></tr>
          <tr><td>aircraft_id</td><td><%=aircraftMap.get("aircraft_id")%></td></tr>
          <tr><td>airline_id</td><td><%=aircraftMap.get("airline_id")%></td></tr>
          <tr><td>number_of_seats</td><td><%=aircraftMap.get("number_of_seats")%></td></tr>
          <tr><td>model</td><td><%=aircraftMap.get("model")%></td></tr>
        </table>
        <% } %>
      </div>
      <div>
        <% if (aircraftMap!=null) { %>
        <form method="post">
          <input type="hidden" name="action" value="editAircraft"/>
          <input type="hidden" name="aircraftId" value="<%=aircraftMap.get("aircraft_id")%>"/>
          <label>Airline:</label>
          <select name="airlineId">
            <% for (Map<String,String> a: airlineList) { %>
              <option value="<%=a.get("id")%>" <%=a.get("id").equals(aircraftMap.get("airline_id"))?"selected":""%>>
                <%=a.get("id")%> – <%=a.get("name")%>
              </option>
            <% } %>
          </select>
          <label>Seats:</label><input name="seats" value="<%=aircraftMap.get("number_of_seats")%>"/>
          <label>Model:</label><input name="model" value="<%=aircraftMap.get("model")%>"/>
          <button type="submit">Update Aircraft</button>
        </form>
        <% } else { %>
          <em>Search an Aircraft to edit.</em>
        <% } %>
      </div>
    </div>
  </div>

  <!-- Manage Flight -->
  <div class="section">
    <h2>Manage Flight</h2>
    <div class="split">
      <div>
        <form method="post">
          <input type="hidden" name="action" value="addFlight"/>
          <label>Flight ID:</label><input name="flightId"/>
          <label>Is Domestic (0/1):</label><input name="isDomestic"/>
          <label>Days Op:</label><input name="daysOp"/>
          <label>Arrival Airport:</label><input name="arrivalId"/>
          <label>Departure Airport:</label><input name="departureId"/>
          <label>Arrival Time (yyyy-MM-dd HH:mm:ss):</label><input name="arrivalTime"/>
          <label>Departure Time:</label><input name="departureTime"/>
          <label>Aircraft ID:</label><input name="aircraftId"/>
          <label>Airline ID:</label><input name="airlineId"/>
          <label>Stops:</label><input name="stops"/>
          <label>Price:</label><input name="price"/>
          <button type="submit">Add Flight</button>
        </form>
        <form method="post">
          <input type="hidden" name="action" value="deleteFlight"/>
          <label>Flight ID to Delete:</label><input name="flightId"/>
          <button type="submit">Delete Flight</button>
        </form>
        <form method="post">
          <input type="hidden" name="action" value="searchFlight"/>
          <label>Search Flight ID:</label><input name="searchFlightId"/>
          <button type="submit">Search Flight</button>
        </form>
        <% if (flightMap!=null) { %>
        <table>
          <tr>
            <th>flight_id</th><th>is_Domestic</th><th>days_of_operation</th>
            <th>departure_airport_id</th><th>arrival_airport_id</th>
            <th>departure_time</th><th>arrival_time</th>
            <th>aircraft_id</th><th>airline_id</th>
            <th>number_of_stops</th><th>price</th><th>duration</th>
          </tr>
          <tr>
            <td><%=flightMap.get("flight_id")%></td>
            <td><%=flightMap.get("is_Domestic")%></td>
            <td><%=flightMap.get("days_of_operation")%></td>
            <td><%=flightMap.get("departure_airport_id")%></td>
            <td><%=flightMap.get("arrival_airport_id")%></td>
            <td><%=flightMap.get("departure_time")%></td>
            <td><%=flightMap.get("arrival_time")%></td>
            <td><%=flightMap.get("aircraft_id")%></td>
            <td><%=flightMap.get("airline_id")%></td>
            <td><%=flightMap.get("number_of_stops")%></td>
            <td><%=flightMap.get("price")%></td>
            <td><%=flightMap.get("duration")%></td>
          </tr>
        </table>
        <% } %>
      </div>
      <div>
        <% if (flightMap!=null) { %>
        <form method="post">
          <input type="hidden" name="action" value="editFlight"/>
          <input type="hidden" name="flightId" value="<%=flightMap.get("flight_id")%>"/>
          <label>Is Domestic:</label><input name="isDomestic" value="<%=flightMap.get("is_Domestic")%>"/>
          <label>Days Op:</label><input name="daysOp" value="<%=flightMap.get("days_of_operation")%>"/>
          <label>Arrival Airport:</label><input name="arrivalId" value="<%=flightMap.get("arrival_airport_id")%>"/>
          <label>Departure Airport:</label><input name="departureId" value="<%=flightMap.get("departure_airport_id")%>"/>
          <label>Arrival Time:</label><input name="arrivalTime" value="<%=flightMap.get("arrival_time")%>"/>
          <label>Departure Time:</label><input name="departureTime" value="<%=flightMap.get("departure_time")%>"/>
          <label>Aircraft ID:</label><input name="aircraftId" value="<%=flightMap.get("aircraft_id")%>"/>
          <label>Airline ID:</label><input name="airlineId" value="<%=flightMap.get("airline_id")%>"/>
          <label>Stops:</label><input name="stops" value="<%=flightMap.get("number_of_stops")%>"/>
          <label>Price:</label><input name="price" value="<%=flightMap.get("price")%>"/>
          <button type="submit">Update Flight</button>
        </form>
        <% } else { %>
          <em>Search a Flight to edit.</em>
        <% } %>
      </div>
    </div>
  </div>

  <!-- Manage Ticket -->
  <div class="section">
    <h2>Manage Ticket</h2>
    <div class="split">
      <div>
        <form method="post">
          <input type="hidden" name="action" value="addTicket"/>
          <label>Ticket ID:</label><input name="ticketId"/>
          <label>First Name:</label><input name="firstName"/>
          <label>Last Name:</label><input name="lastName"/>
          <label>Status:</label><input name="status"/>
          <label>Seat Number:</label><input name="seatNumber"/>
          <label>Total Fare:</label><input name="totalFare"/>
          <label>Purchase DateTime:</label><input name="purchaseDateTime"/>
          <label>Booking Fee:</label><input name="bookingFee"/>
          <label>Class:</label><input name="ticketClass"/>
          <label>Customer UID:</label><input name="uid"/>
          <label>Promoted Flag:</label><input name="promotedFlag"/>
          <button type="submit">Add Ticket</button>
        </form>
        <form method="post">
          <input type="hidden" name="action" value="searchTicket"/>
          <label>Search Ticket ID:</label><input name="searchTicketId"/>
          <button type="submit">Search Ticket</button>
        </form>
        <% if (ticketMap!=null) { %>
        <table>
          <tr><th>Field</th><th>Value</th></tr>
          <% for (Map.Entry<String,Object> e : ticketMap.entrySet()) { %>
            <tr><td><%= e.getKey() %></td><td><%= e.getValue() %></td></tr>
          <% } %>
        </table>
        <% } %>
      </div>
      <div>
        <% if (ticketMap!=null) { %>
        <form method="post">
          <input type="hidden" name="action" value="editTicket"/>
          <input type="hidden" name="ticketId" value="<%=ticketMap.get("Ticket_ID")%>"/>
          <label>First Name:</label><input name="firstName" value="<%=ticketMap.get("First_Name")%>"/>
          <label>Last Name:</label><input name="lastName" value="<%=ticketMap.get("Last_Name")%>"/>
          <label>Status:</label><input name="status" value="<%=ticketMap.get("Status")%>"/>
          <label>Seat Number:</label><input name="seatNumber" value="<%=ticketMap.get("Seat_Number")%>"/>
          <label>Total Fare:</label><input name="totalFare" value="<%=ticketMap.get("Total_Fare")%>"/>
          <label>Purchase DateTime:</label><input name="purchaseDateTime" value="<%=ticketMap.get("Purchase_DateTime")%>"/>
          <label>Booking Fee:</label><input name="bookingFee" value="<%=ticketMap.get("Booking_Fee")%>"/>
          <label>Class:</label><input name="ticketClass" value="<%=ticketMap.get("Class")%>"/>
          <label>Customer UID:</label><input name="uid" value="<%=ticketMap.get("uid")%>"/>
          <label>Promoted Flag:</label><input name="promotedFlag" value="<%=ticketMap.get("promoted_flag")%>"/>
          <button type="submit">Update Ticket</button>
        </form>
        <% } else { %>
          <em>Search a Ticket to edit.</em>
        <% } %>
      </div>
    </div>
  </div>

  <!-- List Flights by Airport -->
  <div class="section">
    <h2>Flights for Airport</h2>
    <form method="post">
      <input type="hidden" name="action" value="listFlights"/>
      <label>Airport ID:</label><input name="listAirportId"/>
      <button type="submit">List Flights</button>
    </form>
    <% if (flightsForAirport != null) { %>
      <table>
        <tr>
          <th>Flight ID</th><th>Domestic?</th><th>Days Op</th>
          <th>Dep Airport</th><th>Arr Airport</th>
          <th>Dep Time</th><th>Arr Time</th>
          <th>Aircraft</th><th>Airline</th><th>Stops</th><th>Price</th>
        </tr>
        <% for (Map<String,Object> f : flightsForAirport) { %>
        <tr>
          <td><%= f.get("flight_id") %></td>
          <td><%= f.get("is_Domestic") %></td>
          <td><%= f.get("days_of_operation") %></td>
          <td><%= f.get("departure_airport_id") %></td>
          <td><%= f.get("arrival_airport_id") %></td>
          <td><%= f.get("departure_time") %></td>
          <td><%= f.get("arrival_time") %></td>
          <td><%= f.get("aircraft_id") %></td>
          <td><%= f.get("airline_id") %></td>
          <td><%= f.get("number_of_stops") %></td>
          <td><%= f.get("price") %></td>
        </tr>
        <% } %>
      </table>
    <% } %>
  </div>
</body>
</html>
