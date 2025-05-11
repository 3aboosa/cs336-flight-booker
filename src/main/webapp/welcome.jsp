<%@ page language="java"
         contentType="text/html; charset=ISO-8859-1"
         pageEncoding="ISO-8859-1"
         import="java.sql.*, java.util.*, java.math.BigDecimal, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="ISO-8859-1">
  <title>Flight Search</title>
  <style>
    body { margin:0; padding:20px; font-family:Arial,sans-serif; }
    h1 { margin-top:0; }
    .layout { display:flex; align-items:flex-start; }
    #filters {
      width:260px;
      padding-right:20px;
      border-right:1px solid #ccc;
      box-sizing:border-box;
    }
    #results {
      flex:1;
      padding-left:20px;
      box-sizing:border-box;
    }
    .form-row { margin-bottom:1em; }
    table { width:100%; border-collapse:collapse; margin-bottom:2em; }
    th, td { border:1px solid #ddd; padding:8px; text-align:left; }
    tr:nth-child(even){ background:#f9f9f9; }
    input[type="text"] { width:60px; }
  </style>
  <script>
    function toggleFilters(){
      var oneWay = document.getElementById('oneWay').checked;
      document.getElementById('returnRow').style.display   = oneWay ? 'none' : 'block';
      var tf = document.getElementById('timeFilters');
      if(tf) tf.style.display = oneWay ? 'block' : 'none';
    }
    window.addEventListener('DOMContentLoaded', toggleFilters);
  </script>
</head>
<body>
<%
  // Prevent caching
  response.setHeader("Cache-Control","no-cache,no-store,must-revalidate");
  response.setHeader("Pragma","no-cache");
  response.setDateHeader("Expires",0);

  // Auth
  String username = (String)session.getAttribute("username");
  if(username==null){
    response.sendRedirect("login.jsp");
    return;
  }

  // Load first name
  String firstName="";
  try(Connection c=new ApplicationDB().getConnection();
      PreparedStatement p=c.prepareStatement(
        "SELECT first_name FROM individual WHERE username=?"
      )){
    p.setString(1,username);
    try(ResultSet r=p.executeQuery()){
      if(r.next()) firstName=r.getString("first_name");
    }
  }catch(Exception ignored){}

  // Read params
  String tripType     = request.getParameter("tripType"),
         from         = request.getParameter("Source"),
         to           = request.getParameter("Destination"),
         depDate      = request.getParameter("departure"),
         retDate      = request.getParameter("returnDate"),
         minPrice     = request.getParameter("minPrice"),
         maxPrice     = request.getParameter("maxPrice"),
         selAir       = request.getParameter("airline"),
         sortBy       = request.getParameter("sortBy"),
         sortDir      = request.getParameter("sortDir");
  boolean flexible    = request.getParameter("flexibleDates")!=null;
  String[] stopsArr   = request.getParameterValues("stops");
  String depTimeStart = request.getParameter("depTimeStart"),
         depTimeEnd   = request.getParameter("depTimeEnd"),
         arrTimeStart = request.getParameter("arrTimeStart"),
         arrTimeEnd   = request.getParameter("arrTimeEnd");
  boolean isRound = "roundTrip".equals(tripType);

  // Result lists
  List<Map<String,Object>> outboundList = new ArrayList<>(),
                             returnList   = new ArrayList<>();

  // Query building...
  if(from!=null && to!=null && depDate!=null && !depDate.isEmpty()){
    try(Connection con=new ApplicationDB().getConnection()){
      // Tail for one-way filters & sort
      StringBuilder tail = new StringBuilder();
      if(!isRound){
        if(minPrice!=null&&!minPrice.isEmpty()) tail.append("AND price>=? ");
        if(maxPrice!=null&&!maxPrice.isEmpty()) tail.append("AND price<=? ");
        if(stopsArr!=null){
          tail.append("AND number_of_stops IN (")
              .append(String.join(",", Collections.nCopies(stopsArr.length,"?")))
              .append(") ");
        }
        if(depTimeStart!=null&&!depTimeStart.isEmpty()) tail.append("AND TIME(departure_time)>=? ");
        if(depTimeEnd  !=null&&!depTimeEnd.isEmpty())   tail.append("AND TIME(departure_time)<=? ");
        if(arrTimeStart!=null&&!arrTimeStart.isEmpty()) tail.append("AND TIME(arrival_time)>=? ");
        if(arrTimeEnd  !=null&&!arrTimeEnd.isEmpty())   tail.append("AND TIME(arrival_time)<=? ");
      }
      if(selAir!=null&&!selAir.isEmpty()) tail.append("AND airline_id=? ");
      if(!isRound && sortBy!=null&&!sortBy.isEmpty()){
        tail.append("ORDER BY ")
            .append("duration".equals(sortBy)?"duration":sortBy)
            .append(" ").append(sortDir!=null?sortDir:"ASC");
      }

      // OUTBOUND
      StringBuilder outSql = new StringBuilder(
        "SELECT *, TIMESTAMPDIFF(MINUTE,departure_time,arrival_time) AS duration "
        +"FROM flights WHERE departure_airport_id=? AND arrival_airport_id=? "
      );
      if(flexible){
        outSql.append("AND DATE(departure_time) BETWEEN DATE_SUB(?,INTERVAL 3 DAY) ")
              .append("AND DATE_ADD(?,INTERVAL 3 DAY) ");
      } else {
        outSql.append("AND DATE(departure_time)=? ");
      }
      outSql.append(tail);

      try(PreparedStatement pout=con.prepareStatement(outSql.toString())){
        int idx=1;
        pout.setString(idx++,from);
        pout.setString(idx++,to);
        if(flexible){
          pout.setString(idx++,depDate);
          pout.setString(idx++,depDate);
        } else {
          pout.setString(idx++,depDate);
        }
        if(!isRound){
          if(minPrice!=null&&!minPrice.isEmpty()) pout.setBigDecimal(idx++,new BigDecimal(minPrice));
          if(maxPrice!=null&&!maxPrice.isEmpty()) pout.setBigDecimal(idx++,new BigDecimal(maxPrice));
          if(stopsArr!=null) for(String s:stopsArr) pout.setInt(idx++,Integer.parseInt(s));
          if(depTimeStart!=null&&!depTimeStart.isEmpty()){
            String v=depTimeStart.length()==5?depTimeStart+":00":depTimeStart;
            pout.setTime(idx++,Time.valueOf(v));
          }
          if(depTimeEnd!=null&&!depTimeEnd.isEmpty()){
            String v=depTimeEnd.length()==5?depTimeEnd+":00":depTimeEnd;
            pout.setTime(idx++,Time.valueOf(v));
          }
          if(arrTimeStart!=null&&!arrTimeStart.isEmpty()){
            String v=arrTimeStart.length()==5?arrTimeStart+":00":arrTimeStart;
            pout.setTime(idx++,Time.valueOf(v));
          }
          if(arrTimeEnd!=null&&!arrTimeEnd.isEmpty()){
            String v=arrTimeEnd.length()==5?arrTimeEnd+":00":arrTimeEnd;
            pout.setTime(idx++,Time.valueOf(v));
          }
        }
        if(selAir!=null&&!selAir.isEmpty()) pout.setString(idx++,selAir);

        try(ResultSet rs=pout.executeQuery()){
          while(rs.next()){
            Map<String,Object> m=new HashMap<>();
            m.put("flight_id", rs.getString("flight_id"));
            m.put("price",     rs.getBigDecimal("price"));
            m.put("departure_time",rs.getTimestamp("departure_time"));
            m.put("arrival_time",  rs.getTimestamp("arrival_time"));
            m.put("departure_airport_id", rs.getString("departure_airport_id"));
            m.put("arrival_airport_id",   rs.getString("arrival_airport_id"));
            m.put("number_of_stops", rs.getInt("number_of_stops"));
            m.put("airline_id",      rs.getString("airline_id"));
            m.put("duration",        rs.getInt("duration"));
            outboundList.add(m);
          }
        }
      }

      // RETURN (round-trip)
      if(isRound && retDate!=null && !retDate.isEmpty()){
        StringBuilder retSql=new StringBuilder(
          "SELECT *, TIMESTAMPDIFF(MINUTE,departure_time,arrival_time) AS duration "
          +"FROM flights WHERE departure_airport_id=? AND arrival_airport_id=? "
        );
        if(flexible){
          retSql.append("AND DATE(departure_time) BETWEEN DATE_SUB(?,INTERVAL 3 DAY) ")
                .append("AND DATE_ADD(?,INTERVAL 3 DAY) ");
        } else {
          retSql.append("AND DATE(departure_time)=? ");
        }
        if(selAir!=null&&!selAir.isEmpty()) retSql.append("AND airline_id=? ");

        try(PreparedStatement pret=con.prepareStatement(retSql.toString())){
          int j=1;
          pret.setString(j++,to);
          pret.setString(j++,from);
          if(flexible){
            pret.setString(j++,retDate);
            pret.setString(j++,retDate);
          } else {
            pret.setString(j++,retDate);
          }
          if(selAir!=null&&!selAir.isEmpty()) pret.setString(j++,selAir);

          try(ResultSet rr=pret.executeQuery()){
            while(rr.next()){
              Map<String,Object> m=new HashMap<>();
              m.put("flight_id", rr.getString("flight_id"));
              m.put("price",     rr.getBigDecimal("price"));
              m.put("departure_time",rr.getTimestamp("departure_time"));
              m.put("arrival_time",  rr.getTimestamp("arrival_time"));
              m.put("departure_airport_id", rr.getString("departure_airport_id"));
              m.put("arrival_airport_id",   rr.getString("arrival_airport_id"));
              m.put("number_of_stops", rr.getInt("number_of_stops"));
              m.put("airline_id",      rr.getString("airline_id"));
              m.put("duration",        rr.getInt("duration"));
              returnList.add(m);
            }
          }
        }
      }

    } catch(Exception ignored){}
  }

  // Build round-trip options + totals
  List<Map<String,Object>> tripOptions=new ArrayList<>();
  if(isRound){
    BigDecimal minP = (minPrice!=null&&!minPrice.isEmpty())?new BigDecimal(minPrice):null;
    BigDecimal maxP = (maxPrice!=null&&!maxPrice.isEmpty())?new BigDecimal(maxPrice):null;
    Set<Integer> stopsSet=new HashSet<>();
    if(stopsArr!=null) for(String s:stopsArr) stopsSet.add(Integer.parseInt(s));

    for(var o:outboundList) for(var r:returnList){
      BigDecimal pO=(BigDecimal)o.get("price"), pR=(BigDecimal)r.get("price");
      int sO=(Integer)o.get("number_of_stops"), sR=(Integer)r.get("number_of_stops"),
          dO=(Integer)o.get("duration"),        dR=(Integer)r.get("duration");
      BigDecimal totalPrice=pO.add(pR);
      int totalStops=sO+sR, totalDuration=dO+dR;

      if(minP!=null && totalPrice.compareTo(minP)<0) continue;
      if(maxP!=null && totalPrice.compareTo(maxP)>0) continue;
      if(!stopsSet.isEmpty()){
        boolean ok=false;
        for(int cat:stopsSet){
          if((cat<2 && totalStops==cat) || (cat>=2 && totalStops>=2)){ ok=true; break; }
        }
        if(!ok) continue;
      }

      Map<String,Object> opt=new HashMap<>();
      opt.put("out",o);
      opt.put("ret",r);
      opt.put("totalPrice",totalPrice);
      opt.put("totalStops",totalStops);
      opt.put("totalDuration",totalDuration);
      tripOptions.add(opt);
    }

    if(sortBy!=null&&!sortBy.isEmpty()){
      final int dir="DESC".equals(sortDir)?-1:1;
      tripOptions.sort((a,b)->{
        switch(sortBy){
          case "price":
            return ((BigDecimal)a.get("totalPrice"))
                   .compareTo((BigDecimal)b.get("totalPrice"))*dir;
          case "duration":
            return ((Integer)a.get("totalDuration"))
                   .compareTo((Integer)b.get("totalDuration"))*dir;
          default:
            return 0;
        }
      });
    }
  }
%>

<style>
  header {
    position: relative;
    padding: 1em;
    background: #f5f5f5;
  }

  .top-links {
    position: absolute;
    top: 1em;    
    right: 1em; 
  }

  .top-links a {
    margin-left: 1em;
    text-decoration: none;
    color: #007bff;
  }
</style>

<header>
  <div class="top-links">
    <a href="browseQuestions.jsp">FAQ</a>
    <a href="myFlights.jsp">View My Flights</a>
    <a href="handleLogout.jsp">Logout</a>
  </div>
  <h1>Welcome, <%= firstName %>!</h1>
</header>


<div class="layout">
  <!-- Left: filters + search -->
  <div id="filters">
    <form method="get">
      <!-- Trip type -->
      <div class="form-row">
        <input type="radio" id="oneWay" name="tripType" value="oneWay"
          <%= tripType==null||"oneWay".equals(tripType)?"checked":"" %>
          onchange="toggleFilters()" />
        <label for="oneWay">One-Way</label>

        <input type="radio" id="roundTrip" name="tripType" value="roundTrip"
          <%= "roundTrip".equals(tripType)?"checked":"" %>
          onchange="toggleFilters()" />
        <label for="roundTrip">Round-Trip</label>
      </div>

      <!-- From/To -->
      <div class="form-row">
        <label>From:</label>
        <input type="text" name="Source" value="<%=from!=null?from:""%>" required>
        <label>To:</label>
        <input type="text" name="Destination" value="<%=to!=null?to:""%>" required>
      </div>

      <!-- Dep/Return dates -->
      <div class="form-row">
        <label>Departure:</label>
        <input type="date" name="departure"
          value="<%=depDate!=null?depDate:""%>" required>
      </div>
      <div class="form-row" id="returnRow">
        <label>Return:</label>
        <input type="date" name="returnDate"
          value="<%=retDate!=null?retDate:""%>">
      </div>

      <div class="form-row">
        <input type="checkbox" name="flexibleDates" id="flexibleDates"
          <%=flexible?"checked":""%>/>
        <label for="flexibleDates">Flexible Dates by 3 days</label>
      </div>

      <!-- Sort -->
      <div class="form-row">
        <strong>Sort By:</strong>
        <select name="sortBy">
          <option value=""   <%= "".equals(sortBy)?"selected":"" %>>--</option>
          <option value="price"          <%= "price".equals(sortBy)?"selected":""%>>Price</option>
          <option value="departure_time" <%= "departure_time".equals(sortBy)?"selected":""%>>Take-off</option>
          <option value="arrival_time"   <%= "arrival_time".equals(sortBy)?"selected":""%>>Landing</option>
          <option value="duration"       <%= "duration".equals(sortBy)?"selected":""%>>Duration</option>
        </select>
        <select name="sortDir">
          <option value="ASC"  <%= "ASC".equals(sortDir)?"selected":""%>>Asc</option>
          <option value="DESC" <%= "DESC".equals(sortDir)?"selected":""%>>Desc</option>
        </select>
      </div>

      <!-- Sidebar filters -->
      <div class="form-row">
        <strong>Stops</strong><br/>
        <label><input type="checkbox" name="stops" value="0"
          <%= stopsArr!=null&&Arrays.asList(stopsArr).contains("0")?"checked":""%>/>Nonstop</label><br/>
        <label><input type="checkbox" name="stops" value="1"
          <%= stopsArr!=null&&Arrays.asList(stopsArr).contains("1")?"checked":""%>/>1 stop</label><br/>
        <label><input type="checkbox" name="stops" value="2"
          <%= stopsArr!=null&&Arrays.asList(stopsArr).contains("2")?"checked":""%>/>2+ stops</label>
      </div>

      <div class="form-row">
        <strong>Price</strong><br/>
        <input type="text" name="minPrice" placeholder="Min"
               value="<%=minPrice!=null?minPrice:""%>"/> to
        <input type="text" name="maxPrice" placeholder="Max"
               value="<%=maxPrice!=null?maxPrice:""%>"/>
      </div>

      <div class="form-row">
        <strong>Airline</strong><br/>
        <select name="airline">
          <option value="">--</option>
          <%
            try(Connection c=new ApplicationDB().getConnection();
                PreparedStatement ps=c.prepareStatement(
                  "SELECT airline_id, Name FROM airline ORDER BY Name"
                );
                ResultSet rs=ps.executeQuery()) {
              while(rs.next()){
                String id=rs.getString("airline_id"),
                       nm=rs.getString("Name");
          %>
            <option value="<%=id%>" <%=id.equals(selAir)?"selected":""%>>
              <%=nm%>
            </option>
          <%
              }
            }
          %>
        </select>
      </div>

      <!-- Time filters (one-way only) -->
      <div id="timeFilters">
        <div class="form-row">
          <strong>Take-off Time</strong><br/>
          From <input type="time" name="depTimeStart" step="60"
                      value="<%=depTimeStart!=null?depTimeStart:""%>"/>
          To   <input type="time" name="depTimeEnd"   step="60"
                      value="<%=depTimeEnd!=null?depTimeEnd:""%>"/>
        </div>
        <div class="form-row">
          <strong>Landing Time</strong><br/>
          From <input type="time" name="arrTimeStart" step="60"
                      value="<%=arrTimeStart!=null?arrTimeStart:""%>"/>
          To   <input type="time" name="arrTimeEnd"   step="60"
                      value="<%=arrTimeEnd!=null?arrTimeEnd:""%>"/>
        </div>
      </div>

      <div class="form-row">
        <button type="submit">Search</button>
      </div>
    </form>
  </div>

  <!-- Right: results, starting at the very top -->
  <div id="results">
    <% if(isRound){ 
         if(tripOptions.isEmpty()){ %>
      <h2>No matching round-trip options.</h2>
    <% } else {
         for(var opt:tripOptions){
           Map<String,Object> o=(Map<String,Object>)opt.get("out"),
                               r=(Map<String,Object>)opt.get("ret");
    %>
      <table>
        <tr style="background:#eee;">
          <th>Reserve</th>
          <th>ID</th><th>Price</th><th>Dep</th><th>Arr</th>
          <th>From</th><th>To</th><th>Stops</th><th>Airline</th><th>Dur</th>
        </tr>
        <tr>
          <td rowspan="3">
            <input type="checkbox"
              onclick="location='reserve.jsp?outId=<%=o.get("flight_id")%>&retId=<%=r.get("flight_id")%>'"/>
          </td>
          <td><%=o.get("flight_id")%></td>
          <td><%=o.get("price")%></td>
          <td><%=o.get("departure_time")%></td>
          <td><%=o.get("arrival_time")%></td>
          <td><%=o.get("departure_airport_id")%></td>
          <td><%=o.get("arrival_airport_id")%></td>
          <td><%=o.get("number_of_stops")%></td>
          <td><%=o.get("airline_id")%></td>
          <td><%=o.get("duration")%></td>
        </tr>
        <tr>
          <td><%=r.get("flight_id")%></td>
          <td><%=r.get("price")%></td>
          <td><%=r.get("departure_time")%></td>
          <td><%=r.get("arrival_time")%></td>
          <td><%=r.get("departure_airport_id")%></td>
          <td><%=r.get("arrival_airport_id")%></td>
          <td><%=r.get("number_of_stops")%></td>
          <td><%=r.get("airline_id")%></td>
          <td><%=r.get("duration")%></td>
        </tr>
        <tr style="font-weight:bold;">
          <td colspan="2">Totals</td>
          <td><%=opt.get("totalPrice")%></td>
          <td colspan="2"></td>
          <td colspan="2">Stops: <%=opt.get("totalStops")%></td>
          <td colspan="2">Dur: <%=opt.get("totalDuration")%> min</td>
        </tr>
      </table>
    <%   }
       }
     } else { %>

      <h2>Available Flights</h2>
      <table>
        <tr>
          <th>Reserve</th><th>ID</th><th>Price</th>
          <th>Dep Time</th><th>Arr Time</th>
          <th>From</th><th>To</th><th>Stops</th>
          <th>Airline</th><th>Duration</th>
        </tr>
        <% for(Map<String,Object> f: outboundList){ %>
        <tr>
          <td><input type="checkbox"
            onclick="location='reserve.jsp?flightId=<%=f.get("flight_id")%>'"/></td>
          <td><%=f.get("flight_id")%></td>
          <td><%=f.get("price")%></td>
          <td><%=f.get("departure_time")%></td>
          <td><%=f.get("arrival_time")%></td>
          <td><%=f.get("departure_airport_id")%></td>
          <td><%=f.get("arrival_airport_id")%></td>
          <td><%=f.get("number_of_stops")%></td>
          <td><%=f.get("airline_id")%></td>
          <td><%=f.get("duration")%></td>
        </tr>
        <% } %>
      </table>

    <% } %>
  </div>
</div>
</body>
</html>
