window.plugins.line =
  bind: (div, item) ->
  emit: (div, item) ->
    wiki.getScript '/js/d3/d3.js', ->
      div.append '''
        <style>
        svg {
          font: 10px sans-serif;
        }

        .rule line {
          stroke: #eee;
          shape-rendering: crispEdges;
        }

        .rule line.axis {
          stroke: #000;
        }

        .line {
          fill: none;
          stroke: steelblue;
          stroke-width: 1.5px;
        }

        circle.line {
          fill: #fff;
        }
        </style>
      '''

      series = wiki.getData()[0]
      console.log series
      data = if (start = series[0][0]) > 1000000000000 # js time
        ({x: (p[0]-start)/24/3600/1000, y:p[1]} for p in series)
      else if start > 1000000000 # unix time
        ({x: (p[0]-start)/24/3600, y:p[1]} for p in series)
      else
        ({x: new Date(p.Date), y:p.Price*1} for p in series)

      w = 380
      h = 275
      p = 40
      extent = (f) ->
        [lo, hi] = [d3.min(data,f), d3.max(data,f)]
        step = Math.pow 10, Math.floor Math.log(hi-lo) / Math.log(10)
        [step*Math.floor(lo/step), step*Math.ceil(hi/step)]
      x = d3.time.scale().domain(extent (p)->p.x).range([ 0, w ])
      y = d3.scale.linear().domain(extent (p)->p.y).range([ h, 0 ])

      vis = d3.select(div.get(0))
        .data([data])
        .append("svg")
        .attr("width", w + p * 2)
        .attr("height", h + p * 2)
        .append("g")
        .attr("transform", "translate(#{p},#{p})")

      rules = vis.selectAll("g.rule")
        .data(x.ticks(10))
        .enter().append("g")
        .attr("class", "rule")

      rules.append("line")
        .attr("x1", x)
        .attr("x2", x)
        .attr("y1", 0)
        .attr("y2", h - 1)

      rules.append("line")
        .attr("class", (d)-> d ? null : "axis" )
        .attr("y1", y)
        .attr("y2", y)
        .attr("x1", 0)
        .attr("x2", w + 1)

      rules.append("text")
        .attr("x", x)
        .attr("y", h + 3)
        .attr("dy", ".71em")
        .attr("text-anchor", "middle")
        .text(x.tickFormat(10))

      rules.append("text")
        .attr("y", y)
        .attr("x", -3)
        .attr("dy", ".35em")
        .attr("text-anchor", "end")
        .text(y.tickFormat(10))

      vis.append("path")
        .attr("class", "line")
        .attr("d", d3.svg.line()
        .x((d)-> x(d.x))
        .y((d)-> y(d.y)))

      vis.selectAll("circle.line")
        .data(data)
        .enter().append("circle")
        .attr("class", "line")
        .attr("cx", (d)-> x(d.x))
        .attr("cy", (d)-> y(d.y))
        .attr("r", 3.5)
        .on('mouseover', -> d3.select(this).attr('r', 8))
        .on('mouseout',  -> d3.select(this).attr('r', 3.5))
        .on('click', (d, i) -> console.log d, i)
