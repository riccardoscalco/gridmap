root = exports ? this
root.gridmap = () ->

  # ---- Default Values ------------------------------------------------

  projection = undefined    # d3.geo projection
  side = 10                 # side of the cells in pixel
  key = "id"                # name of the attribute mapping features to data          
  data = undefined          # d3.map() mapping key to data
  features = undefined      # array of map features
  width = 500
  height = 500
  isquantity = undefined    # 
  gridclass = "gridclass"
  mapclass = "mapclass"

  grid = d3.map()

  # --------------------------------------------------------------------

  chart = (selection) ->

    w = width
    h = height

    path = d3.geo.path()
      .projection(projection)

    radius = d3.scale.linear()
      .range([0, side / 2 * 0.9])
        
    # Using `document.elementFromPoint` the specified point must be
    # inside the visible bounds of the document.
    # Original style will be restored after the gridmap is done.
    backup = {
      "position": selection.style("position")
      "top": selection.style("top")
      "left": selection.style("left")
      "opacity": selection.style("opacity")
    }
    selection.style({
      "position": "fixed"
      "top": 0
      "left": 0
      "opacity": 0
    })

    area = d3.map()
    centroid = d3.map()
    for f in features
      area.set(f[key], path.area(f) / (w * h))
      c = path.centroid(f)
      if c then centroid.set(f[key], c)

    svg = selection.append("svg")
        .attr("width", w)
        .attr("height", h)
        .attr("viewBox", "0 0 "+w+" "+h)

    map = svg.append("g")
    map.selectAll("path")
        .data(features)
      .enter().append("path")
        .attr("class", mapclass)
        .attr("data-key", (d) -> d[key] )
      .attr("d", path)
    
    # define the grid
    matrix = map.node().getScreenCTM()
    dy = matrix.f
    dx = matrix.e
    nx = Math.floor(w / side)
    ny = Math.floor(h / side)
    for i in [0..nx-1]
      for j in [0..ny-1]
        x = side * i + side / 2
        y = side * j + side / 2
        element = document.elementFromPoint(x + dx,y + dy)
        if element
          attr = element.getAttribute("data-key")
          if attr
            centroid.remove(attr)
            value = [attr]
          else value = []
        else value = []
        grid.set(i+","+j, {keys: value, x: x, y: y})

    # add not hitted features to the nearest cell
    centroid.forEach((k,v) ->
      i = Math.floor(v[0] / side)
      j = Math.floor(v[1] / side)
      try
        grid.get(i+","+j).keys.push(k)
    )

    density = (a) ->
      if isquantity
      then num = d3.sum((data.get(j) for j in a))
      else num = d3.sum((data.get(j) * area.get(j) for j in a))
      den = d3.sum((area.get(j) for j in a))
      if den then num / den else 0

    dataGrid = ( { value: density(k.keys), x: k.x, y: k.y } for k in grid.values() when k.keys.length)
    dots = map.selectAll(gridclass).data(dataGrid)
    radius.domain([0, d3.max(dataGrid, (d) -> Math.sqrt(d.value))])
    dots.enter().append("circle")
        .attr("cx", (d) -> d.x)
        .attr("cy", (d) -> d.y)
        .attr("r", (d) -> radius(Math.sqrt(d.value)))
        .attr("class", gridclass)

    selection.style(backup)

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

  chart.isquantity = (_) ->
    isquantity = _
    chart

  chart.features = (_) ->
    features = _
    chart

  chart.projection = (_) ->
    projection = _
    chart

  chart.gridclass = (_) ->
    gridclass = _
    chart 

  chart.mapclass = (_) ->
    mapclass = _
    chart 

  # --------------------------------------------------------------------
  
  chart