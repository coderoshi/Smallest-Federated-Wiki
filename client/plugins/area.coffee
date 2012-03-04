window.plugins.area =
  bind: (div, item) ->
  emit: (div, item) ->
    wiki.getScript '/js/d3/d3.js', ->
      wiki.getScript '/js/d3/d3.layout.js', ->
        #wiki.getScript '/js/d3/d3.time.js', ->
        color_wheel = ['blue', 'yellow', 'orange', 'red', 'green', 'brown']
        div.append '''
          <svg width="0" height="0" xmlns="http://www.w3.org/2000/svg">
            <linearGradient id="blue-bg" y1="0%" y2="100%" x1="0%" x2="0%">
              <stop offset="0" stop-color="#35c5d3" />
              <stop offset="1" stop-color="#0c95a4" />
            </linearGradient>
            <linearGradient id="yellow-bg" y1="0%" y2="100%" x1="0%" x2="0%">
              <stop offset="0" stop-color="#fee077" />
              <stop offset="1" stop-color="#e5c34d" />
            </linearGradient>
            <linearGradient id="orange-bg" y1="0%" y2="100%" x1="0%" x2="0%">
              <stop offset="0" stop-color="#f17b59" />
              <stop offset="1" stop-color="#cb502b" />
            </linearGradient>
            <linearGradient id="red-bg" y1="0%" y2="100%" x1="0%" x2="0%">
              <stop offset="0" stop-color="#f44857" />
              <stop offset="1" stop-color="#aa212d" />
            </linearGradient>
            <linearGradient id="green-bg" y1="0%" y2="100%" x1="0%" x2="0%">
              <stop offset="0" stop-color="#a5df5d" />
              <stop offset="1" stop-color="#77bb1e" />
            </linearGradient>
            <linearGradient id="brown-bg" y1="0%" y2="100%" x1="0%" x2="0%">
              <stop offset="0" stop-color="#8b5d46" />
              <stop offset="1" stop-color="#5b3f33" />
            </linearGradient>
          </svg>
          <style>
          svg {
            font: 10px sans-serif;
          }
          svg text {
            color: blue;
          }
          </style>
        '''

        drawXBackground = ->
          @chart.selectAll('path').remove()
          w = 380
          h = 275
          p = 40

          margin = 0
          x = d3.scale.ordinal().domain(['','20" ago','10" ago','now']).rangePoints([0,w])
          xAxis = d3.svg.axis().scale(x).tickSize(h - margin * 2).tickPadding(0).ticks(4)

          xAxisGroup = @chart.append('svg:g')
            .attr('class', 'xTick')
            .call(xAxis)

          xAxisGroup.selectAll('text').attr('y', 0)

        series = wiki.getData()

        console.log series

        data = []

        for page, i in series
          level = []
          color = color_wheel[i % color_wheel.length]
          for p, j in page
            #x = new Date(p[0])
            x = j
            level.push({x : x, y : p[1], c : "c#{i}", fill : "fill:url(##{color}-bg)"})
          data.push(level)

        extent = (f) ->
          [lo, hi] = [d3.min(data,f), d3.max(data,f)]
          step = Math.pow 10, Math.floor Math.log(hi-lo) / Math.log(10)
          [step*Math.floor(lo/step), step*Math.ceil(hi/step)]
        w = 380
        h = 275
        p = 40

        @graph = d3.select(div.get(0)) #d3.select(@elem)
                .append('svg:svg')
                  .attr("width", w).attr("height", h)
        
        ###
        @chart = @graph
                  .append('svg:g')
                    .attr("style", 'background-color:red')
                    .attr("width", w).attr("height", h)
        drawXBackground()
        ###


        stack = d3.layout.stack()(data)
        console.log stack

        mx = d3.max data, (d)-> d.length - 1

        my = d3.max data, (d) ->
          d3.max d, (d)-> d.y0 + d.y

        mz = d3.max data, (d)->
          d3.max d, (d)-> d.y

        mx = 1 if mx == 0
        my = 1 if my == 0

        x = (d)-> d.x * w / mx
        # x = d3.time.scale().domain(extent (p)->p.x).range([ 0, w ])
        y0 = (d)-> h - d.y0 * h / my  #calculate the start point for a value
        y1 = (d)-> h - (d.y + d.y0) * h / my #calculate the end point for a value

        area = d3.svg.area().x(x).y0(y0).y1(y1)

        pathCount = 0
        @graph.attr("width", w).attr("height", h)
        @graph.selectAll('path').remove()
        @graph.selectAll('path')
          .data(stack)
          .enter().append('path').attr('class', ((d)-> d[0].c)).attr('style', ((d)-> d[0].fill))
          .attr('d', area)
