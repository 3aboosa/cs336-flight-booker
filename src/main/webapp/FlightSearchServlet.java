<div id="results">
  <c:choose>
    <!-- Round-trip: show every outbound/return pairing in one table -->
    <c:when test="${not empty returnFlights}">
      <h2>Round-Trip Options</h2>
      <table>
        <tr>
          <th>Reserve</th>
          <!-- Outbound columns -->
          <th>Out ID</th><th>Dep Time</th><th>Arr Time</th><th>From</th><th>To</th>
          <!-- Return columns -->
          <th>Ret ID</th><th>Dep Time</th><th>Arr Time</th><th>From</th><th>To</th>
        </tr>
        <c:forEach var="o" items="${outbound}">
          <c:forEach var="r" items="${returnFlights}">
            <tr>
              <td>
                <input type="checkbox"
                  onclick="location='reserve.jsp?outId=${o.flight_id}&amp;retId=${r.flight_id}'"/>
              </td>
              <!-- Outbound -->
              <td>${o.flight_id}</td>
              <td>${o.departure_time}</td>
              <td>${o.arrival_time}</td>
              <td>${o.departure_airport_id}</td>
              <td>${o.arrival_airport_id}</td>
              <!-- Return -->
              <td>${r.flight_id}</td>
              <td>${r.departure_time}</td>
              <td>${r.arrival_time}</td>
              <td>${r.departure_airport_id}</td>
              <td>${r.arrival_airport_id}</td>
            </tr>
          </c:forEach>
        </c:forEach>
      </table>
    </c:when>

    <!-- One-way: fall back to single table -->
    <c:otherwise>
      <h2>Available Flights</h2>
      <table>
        <tr>
          <th>Reserve</th><th>ID</th><th>Price</th>
          <th>Dep Time</th><th>Arr Time</th>
          <th>From</th><th>To</th>
          <th>Stops</th><th>Airline</th><th>Duration</th>
        </tr>
        <c:forEach var="f" items="${outbound}">
          <tr>
            <td>
              <input type="checkbox"
                onclick="location='reserve.jsp?flightId=${f.flight_id}'"/>
            </td>
            <td>${f.flight_id}</td>
            <td>${f.price}</td>
            <td>${f.departure_time}</td>
            <td>${f.arrival_time}</td>
            <td>${f.departure_airport_id}</td>
            <td>${f.arrival_airport_id}</td>
            <td>${f.number_of_stops}</td>
            <td>${f.airline_id}</td>
            <td>${f.duration}</td>
          </tr>
        </c:forEach>
      </table>
    </c:otherwise>
  </c:choose>
</div>
