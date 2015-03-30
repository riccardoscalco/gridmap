Gridmap
=======

This is an attempt to create dot-grid maps with **d3.js**.

![enter image description here](https://lh3.googleusercontent.com/UU7MLms-Z3fMRoRdEhT7Y1Z4KSHqXE66gyzBwxLJYDI=s0 "gridmap")

--------------------

### API

```
  chart = gridmap()
      .data(data)
      .width(width)
      .height(height)
      .key("id")
      .side(5)
      .isDensity(true)
      .projection(projection)
      .features(features)
      .fill("black");
      
  d3.select("#gridmap").call(chart);
```

----------------------

### Notes
- `data` is a `d3.map()` object linking feature names (`key`) to the associated data. It can be passed in the form of *quantity of population* (`q`) or in the form of *density of population* (`d`), setting `isDensity` to `false` or `true` respectively.
-  `key` is the attribute that identifies the feature (usually an `id`).
-  `side` is the maximum grid-dot diameter in pixel.
-  `projection` is a ` d3.geo.projection`. Use [equal-area](http://en.wikipedia.org/wiki/Map_projection#Equal-area) projections, dotgrid maps assume the projection preserves area measure.
- some map features may be not covered by any grid-dot, in that case the function adds the features data to the grid-dot nearest to the feature centroid. The density value associated to the grid-dot is calculated as: 
    - `sum(d * A)/sum(A)` in the case data si passed as *density of population*
    - `sum(q)/sum(A)` in the case data si passed as *quantity of population*
where  `A` is the feature area and the summation runs over the list of features associated to the grid-dot.


-----------------------------

### Resources

- Code for [point-in-polygon](https://github.com/substack/point-in-polygon)
-  [PNPOLY](http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html) Point Inclusion in Polygon Test (W. Randolph Franklin)
- [Point in Polygon Strategies](http://erich.realtimerendering.com/ptinpoly/)

------

> Written with [StackEdit](https://stackedit.io/).