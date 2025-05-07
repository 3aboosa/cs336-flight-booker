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
    body { margin:0; padding:0; font-family:Arial,sans-serif; }
    .form-row { margin-bottom:1em; }
    table { width:100%; border-collapse:collapse; }
    th, td { border:1px solid #ddd; padding:8px; text-align:left; }
    tr:nth-child(even){background:#f9f9f9;}
  </style>
  <script>
    function toggleReturnField(){
      var isOneWay = document.getElementById('oneWay').checked;
      document.getElementById('returnField').style.display = isOneWay?'none':'block';
    }
    document.addEventListener('DOMContentLoaded',function(){
      document.getElementById('oneWay').addEventListener('change',toggleReturnField);
      document.getElementById('roundTrip').addEventListener('change',toggleReturnField);
      toggleReturnField();
    });
  </script>
</head>
<body>
<%
  // no‐cache headers
  response.setHeader("Cache-Control","no-cache,no-store,must-revalidate");
  response.setHeader("Pragma","no-cache");
  response.setDateHeader("Expires",0);

  // auth check & fetch first name
  if(session.getAttribute("username")==null){
    response.sendRedirect("login.jsp"); return;
  }
  String user=(String)session.getAttribute("username"), firstName="";
  try{
    ApplicationDB db=new ApplicationDB();
    Connection c=db.getConnection();
    PreparedStatement p=c.prepareStatement("SELECT first_name FROM individual WHERE username=?");
    p.setString(1,user);
    ResultSet r=p.executeQuery();
    if(r.next()) firstName=r.getString("first_name");
    r.close(); p.close(); c.close();
  } catch(Exception e){
    out.println("Error: "+e.getMessage());
  }
%>

<div><a href="handleLogout.jsp">Logout</a></div>
<h1>Welcome, <%= firstName %>!</h1>

<form method="get">
  <!-- Trip type -->
  <div class="form-row">
    <input type="radio" id="oneWay" name="tripType" value="oneWay"
      <%= "oneWay".equals(request.getParameter("tripType")) || request.getParameter("tripType")==null ? "checked" : "" %> >
    <label for="oneWay">One-Way</label>
    <input type="radio" id="roundTrip" name="tripType" value="roundTrip"
      <%= "roundTrip".equals(request.getParameter("tripType")) ? "checked" : "" %> >
    <label for="roundTrip">Round-Trip</label>
  </div>

  <!-- From / To -->
  <div class="form-row">
    <label>From:</label>
    <input type="text" name="Source"
      value="<%= request.getParameter("Source")==null?"":request.getParameter("Source") %>" required>
    <label>To:</label>
    <input type="text" name="Destination"
      value="<%= request.getParameter("Destination")==null?"":request.getParameter("Destination") %>" required>
  </div>

  <!-- Dates -->
  <div class="form-row">
    <label>Departure:</label>
    <input type="date" name="departure"
      value="<%= request.getParameter("departure")==null?"":request.getParameter("departure") %>" required>
  </div>
  <div class="form-row" id="returnField">
    <label>Return:</label>
    <input type="date" name="returnDate"
      value="<%= request.getParameter("returnDate")==null?"":request.getParameter("returnDate") %>">
  </div>
  <div class="form-row">
    <input type="checkbox" name="flexibleDates" id="flexibleDates"
      <%= request.getParameter("flexibleDates")!=null?"checked":"" %> >
    <label for="flexibleDates">Flexible Dates (+/−3 Days)</label>
  </div>

  <!-- Price Ranges (checkboxes) -->
  <div class="form-row">
    <strong>Price:</strong>
    <label><input type="checkbox" name="priceRange" value="low"
      <%= Arrays.asList(request.getParameterValues("priceRange")==null?new String[]{}:request.getParameterValues("priceRange")).contains("low")?"checked":"" %>>
      ≤ 300</label>
    <label><input type="checkbox" name="priceRange" value="mid"
      <%= Arrays.asList(request.getParameterValues("priceRange")==null?new String[]{}:request.getParameterValues("priceRange")).contains("mid")?"checked":"" %>>
      300–600</label>
    <label><input type="checkbox" name="priceRange" value="high"
      <%= Arrays.asList(request.getParameterValues("priceRange")==null?new String[]{}:request.getParameterValues("priceRange")).contains("high")?"checked":"" %>>
      > 600</label>
  </div>

  <!-- Stops (checkboxes) -->
  <div class="form-row">
    <strong>Stops:</strong>
    <label><input type="checkbox" name="stops" value="0"
      <%= Arrays.asList(request.getParameterValues("stops")==null?new String[]{}:request.getParameterValues("stops")).contains("0")?"checked":"" %>>0</label>
    <label><input type="checkbox" name="stops" value="1"
      <%= Arrays.asList(request.getParameterValues("stops")==null?new String[]{}:request.getParameterValues("stops")).contains("1")?"checked":"" %>>1</label>
    <label><input type="checkbox" name="stops" value="2"
      <%= Arrays.asList(request.getParameterValues("stops")==null?new String[]{}:request.getParameterValues("stops")).contains("2")?"checked":"" %>>2+</label>
  </div>

  <!-- Airlines (checkboxes) -->
  <div class="form-row">
    <strong>Airline:</strong>
    <%
      String[] allAir = {"AA","DL","BA","UA","SW"};
      String[] selAir = request.getParameterValues("airlines");
      for(String code: allAir){
        boolean checked = selAir!=null && Arrays.asList(selAir).contains(code);
    %>
      <label>
        <input type="checkbox" name="airlines" value="<%=code%>" <%=checked?"checked":""%>>
        <%=code%>
      </label>
    <%
      }
    %>
  </div>

  <!-- Departure Time Range -->
  <div class="form-row">
    <label>Dep Time From:</label>
    <input type="time" name="depTimeStart"
      value="<%= request.getParameter("depTimeStart")==null?"":request.getParameter("depTimeStart") %>">
    <label>To:</label>
    <input type="time" name="depTimeEnd"
      value="<%= request.getParameter("depTimeEnd")==null?"":request.getParameter("depTimeEnd") %>">
  </div>

  <!-- Arrival Time Range -->
  <div class="form-row">
    <label>Arr Time From:</label>
    <input type="time" name="arrTimeStart"
      value="<%= request.getParameter("arrTimeStart")==null?"":request.getParameter("arrTimeStart") %>">
    <label>To:</label>
    <input type="time" name="arrTimeEnd"
      value="<%= request.getParameter("arrTimeEnd")==null?"":request.getParameter("arrTimeEnd") %>">
  </div>

  <!-- Sort Options -->
  <div class="form-row">
    <label>Sort By:</label>
    <select name="sortBy">
      <option value=""   <%= "".equals(request.getParameter("sortBy"))?"selected":"" %>>--</option>
      <option value="price"          <%= "price".equals(request.getParameter("sortBy"))?"selected":"" %>>Price</option>
      <option value="departure_time" <%= "departure_time".equals(request.getParameter("sortBy"))?"selected":""%>>Take-off</option>
      <option value="arrival_time"   <%= "arrival_time".equals(request.getParameter("sortBy"))?"selected":"" %>>Landing</option>
      <option value="duration"       <%= "duration".equals(request.getParameter("sortBy"))?"selected":"" %>>Duration</option>
    </select>
    <select name="sortDir">
      <option value="ASC"  <%= "ASC".equals(request.getParameter("sortDir"))?"selected":"" %>>Asc</option>
      <option value="DESC" <%= "DESC".equals(request.getParameter("sortDir"))?"selected":"" %>>Desc</option>
    </select>
  </div>

  <button type="submit">Search</button>
</form>

<h2>Available Flights</h2>
<table>
  <tr>
    <th>ID</th><th>Price</th><th>Dep Time</th><th>Arr Time</th>
    <th>Dep Loc</th><th>Arr Loc</th><th>Stops</th><th>Airline</th><th>Dur (min)</th>
  </tr>
<%
  // Grab params
  String tripType   = request.getParameter("tripType"),
         from       = request.getParameter("Source"),
         to         = request.getParameter("Destination"),
         depDate    = request.getParameter("departure"),
         retDate    = request.getParameter("returnDate"),
         sortBy     = request.getParameter("sortBy"),
         sortDir    = request.getParameter("sortDir");

  boolean flexible = request.getParameter("flexibleDates") != null;
  String[] priceRange = request.getParameterValues("priceRange");
  String[] stopsArr   = request.getParameterValues("stops");
  String[] airlines   = request.getParameterValues("airlines");
  String depTimeStart = request.getParameter("depTimeStart"),
         depTimeEnd   = request.getParameter("depTimeEnd"),
         arrTimeStart = request.getParameter("arrTimeStart"),
         arrTimeEnd   = request.getParameter("arrTimeEnd");

  if(from!=null && to!=null && depDate!=null && !depDate.isEmpty()){
    try {
      ApplicationDB db=new ApplicationDB();
      Connection con=db.getConnection();

      StringBuilder sql = new StringBuilder(
        "SELECT *, TIMESTAMPDIFF(MINUTE,departure_time,arrival_time) AS duration "
        +"FROM flights WHERE departure_airport_id=? AND arrival_airport_id=? "
      );

      // departure date
      if(flexible){
        sql.append("AND DATE(departure_time) BETWEEN DATE_SUB(?,INTERVAL 3 DAY) ")
           .append("AND DATE_ADD(?,INTERVAL 3 DAY) ");
      } else {
        sql.append("AND DATE(departure_time)=? ");
      }
      // round-trip return
      if("roundTrip".equals(tripType) && retDate!=null && !retDate.isEmpty()){
        if(flexible){
          sql.append("AND DATE(arrival_time) BETWEEN DATE_SUB(?,INTERVAL 3 DAY) ")
             .append("AND DATE_ADD(?,INTERVAL 3 DAY) ");
        } else {
          sql.append("AND DATE(arrival_time)=? ");
        }
      }
      // priceRange filter
      if(priceRange!=null){
        sql.append("AND (");
        for(int i=0;i<priceRange.length;i++){
          if(i>0) sql.append(" OR ");
          switch(priceRange[i]){
            case "low":  sql.append("price<=300"); break;
            case "mid":  sql.append("price BETWEEN 300 AND 600"); break;
            case "high": sql.append("price>600"); break;
          }
        }
        sql.append(") ");
      }
      // stops filter
      if(stopsArr!=null){
        sql.append("AND number_of_stops IN (");
        for(int i=0;i<stopsArr.length;i++){
          if(i>0) sql.append(",");
          sql.append("?");
        }
        sql.append(") ");
      }
      // airlines filter
      if(airlines!=null){
        sql.append("AND airline_id IN (");
        for(int i=0;i<airlines.length;i++){
          if(i>0) sql.append(",");
          sql.append("?");
        }
        sql.append(") ");
      }
      // departure-time window
      if(depTimeStart!=null && !depTimeStart.isEmpty())
        sql.append("AND TIME(departure_time)>=? ");
      if(depTimeEnd!=null   && !depTimeEnd.isEmpty())
        sql.append("AND TIME(departure_time)<=? ");
      // arrival-time window
      if(arrTimeStart!=null && !arrTimeStart.isEmpty())
        sql.append("AND TIME(arrival_time)>=? ");
      if(arrTimeEnd!=null   && !arrTimeEnd.isEmpty())
        sql.append("AND TIME(arrival_time)<=? ");
      // sorting
      if(sortBy!=null && !sortBy.isEmpty()){
        sql.append("ORDER BY ")
           .append("duration".equals(sortBy)?"duration":sortBy)
           .append(" ").append(sortDir!=null?sortDir:"ASC");
      }

      PreparedStatement s = con.prepareStatement(sql.toString());
      int idx=1;
      s.setString(idx++, from);
      s.setString(idx++, to);
      if(flexible){
        s.setString(idx++, depDate);
        s.setString(idx++, depDate);
      } else {
        s.setString(idx++, depDate);
      }
      if("roundTrip".equals(tripType) && retDate!=null && !retDate.isEmpty()){
        if(flexible){
          s.setString(idx++, retDate);
          s.setString(idx++, retDate);
        } else {
          s.setString(idx++, retDate);
        }
      }
      // bind stops
      if(stopsArr!=null){
        for(String st: stopsArr){
          s.setInt(idx++, Integer.parseInt(st));
        }
      }
      // bind airlines
      if(airlines!=null){
        for(String al: airlines){
          s.setString(idx++, al);
        }
      }
      // bind time windows
      if(depTimeStart!=null && !depTimeStart.isEmpty())
        s.setTime(idx++, java.sql.Time.valueOf(depTimeStart));
      if(depTimeEnd!=null   && !depTimeEnd.isEmpty())
        s.setTime(idx++, java.sql.Time.valueOf(depTimeEnd));
      if(arrTimeStart!=null && !arrTimeStart.isEmpty())
        s.setTime(idx++, java.sql.Time.valueOf(arrTimeStart));
      if(arrTimeEnd!=null   && !arrTimeEnd.isEmpty())
        s.setTime(idx++, java.sql.Time.valueOf(arrTimeEnd));

      ResultSet rs = s.executeQuery();
      while(rs.next()){
        out.print("<tr>"
          + "<td>"+rs.getString("flight_id")+"</td>"
          + "<td>"+rs.getBigDecimal("price")+"</td>"
          + "<td>"+rs.getString("departure_time")+"</td>"
          + "<td>"+rs.getString("arrival_time")+"</td>"
          + "<td>"+rs.getString("departure_airport_id")+"</td>"
          + "<td>"+rs.getString("arrival_airport_id")+"</td>"
          + "<td>"+rs.getInt("number_of_stops")+"</td>"
          + "<td>"+rs.getString("airline_id")+"</td>"
          + "<td>"+rs.getInt("duration")+"</td>"
          + "</tr>");
      }
      rs.close(); s.close(); con.close();
    } catch(Exception e){
      response.sendRedirect("login.jsp?error=Database+error");
      return;
    }
  }
%>
</table>
</body>
</html>
