root = exports ? this

# helper functions -----------------------------------------------------

flat = (type, arr) ->
  flatten = (polygon) ->
    polygon.reduce (a, b) -> a.concat [[0,0]].concat b
  switch type
    when "Polygon" then m = flatten arr
    when "MultiPolygon" then m = flatten (flatten polygon for polygon in arr)
  [[0,0]].concat m.concat [[0,0]]

subGrid = (box,side) ->
  x = 1 + Math.floor box[0][0] / side
  y = 1 + Math.floor box[0][1] / side
  x1 = Math.floor box[1][0] / side
  y1 = Math.floor box[1][1] / side
  if x1 >= x and y1 >= y
    ([i, j] for i in [x..x1] for j in [y..y1]).reduce (a, b) -> a.concat b
  else
    []

isInside = (point, vs) ->
  # ray-casting algorithm based on
  # http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
  x = point[0]
  y = point[1]
  inside = false
  j = vs.length - 1
  for i in [0..vs.length-1]
    xi = vs[i][0]
    yi = vs[i][1]
    xj = vs[j][0]
    yj = vs[j][1]
    intersect = ((yi > y) isnt (yj > y)) and 
      (x < (xj - xi) * (y - yi) / (yj - yi) + xi)
    if intersect then inside = !inside
    j = i
  inside

# end helper functions -------------------------------------------------

root.gridmap = () ->

  # ---- Default Values ------------------------------------------------
  
  projection = undefined    # d3.geo projection
  data = undefined          # d3.map() mapping key to data
  features = undefined      # array of map features
  isDensity = undefined     # set to `true` if data define a density

  side = 10                 # side of the cells in pixel
  key = "id"                # name of the attribute mapping features to data
  width = 500
  height = 500
  fill = "#343434"

  grid = d3.map()

  # --------------------------------------------------------------------

  chart = (selection) ->

    w = width
    h = height

    path = d3.geoPath()
      .projection projection

    radius = d3.scaleLinear()
      .range [0, side / 2 * 0.9]
        
    area = d3.map()
    centroid = d3.map()
    for f in features
      area.set f[key], path.area(f) / (w * h)

    svg = selection
        .append "svg"
        .attr "width", w
        .attr "height", h
        .attr "viewBox", "0 0 "+w+" "+h

    map = svg
        .append "g"

    map.selectAll "path"
        .data features 
      .enter()
        .append "path"
        .style "opacity", 0
        .attr "d", path

    # define the grid
    for f in features
      g = f.geometry
      if g.type in ["Polygon","MultiPolygon"]
        box = path.bounds f
        points = subGrid box, side
        value = [f[key]]
        if points.length
          polygon = flat g.type, g.coordinates
          for [i,j] in points
            x = side * i
            y = side * j
            coords = projection.invert [x, y]
            ii = isInside coords, polygon
            if ii
              grid.set i+","+j, {keys: value, x: x, y: y}
        else
          c = path.centroid f 
          if c then centroid.set f[key], c

    # add not hitted features to the nearest cell
    centroid.each (k, v) ->
      i = Math.floor v[0] / side
      j = Math.floor v[1] / side
      try
        grid.get(i+","+j).keys.push(k)

    density = (a) ->
      if isDensity
      then num = d3.sum ( data.get(j) * area.get(j) for j in a )
      else num = d3.sum ( data.get(j)  for j in a )
      den = d3.sum ( area.get(j) for j in a )
      if den then num / den else 0

    dataGrid = ( {
      value: density(k.keys)
      x: k.x
      y: k.y 
    } for k in grid.values() when k.keys.length )
    
    dots = map
      .selectAll ".gridmap-dot"
      .data dataGrid
    
    radius
      .domain [ 0, d3.max dataGrid, (d) -> Math.sqrt d.value ]
 
    # enter
    dots.enter()
        .append "circle"
        .attr "class", "gridmap-dot"
        .attr "cx", (d) -> d.x
        .attr "cy", (d) -> d.y
        .attr "r", (d) -> radius Math.sqrt d.value
        .style "fill", fill


  # ---- Getter/Setter Methods -----------------------------------------

  chart.width = (_) ->
    width = _
    chart

  chart.height = (_) ->
    height = _
    chart

  chart.side = (_) ->
    side = _
    chart

  chart.key = (_) ->
    key = _
    chart

  chart.data = (_) ->
    data = _
    chart

  chart.isDensity = (_) ->
    isDensity = _
    chart

  chart.features = (_) ->
    features = _
    chart

  chart.projection = (_) ->
    projection = _
    chart

  chart.fill = (_) ->
    fill = _
    chart 

  # --------------------------------------------------------------------
  
  chart
