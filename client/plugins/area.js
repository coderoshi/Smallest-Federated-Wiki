(function() {

  window.plugins.area = {
    bind: function(div, item) {},
    emit: function(div, item) {
      return wiki.getScript('/js/d3/d3.js', function() {
        return wiki.getScript('/js/d3/d3.layout.js', function() {
          var area, color, color_wheel, data, drawXBackground, extent, h, i, j, level, mx, my, mz, p, page, pathCount, series, stack, w, x, y0, y1, _len, _len2;
          color_wheel = ['blue', 'yellow', 'orange', 'red', 'green', 'brown'];
          div.append('<svg width="0" height="0" xmlns="http://www.w3.org/2000/svg">\n  <linearGradient id="blue-bg" y1="0%" y2="100%" x1="0%" x2="0%">\n    <stop offset="0" stop-color="#35c5d3" />\n    <stop offset="1" stop-color="#0c95a4" />\n  </linearGradient>\n  <linearGradient id="yellow-bg" y1="0%" y2="100%" x1="0%" x2="0%">\n    <stop offset="0" stop-color="#fee077" />\n    <stop offset="1" stop-color="#e5c34d" />\n  </linearGradient>\n  <linearGradient id="orange-bg" y1="0%" y2="100%" x1="0%" x2="0%">\n    <stop offset="0" stop-color="#f17b59" />\n    <stop offset="1" stop-color="#cb502b" />\n  </linearGradient>\n  <linearGradient id="red-bg" y1="0%" y2="100%" x1="0%" x2="0%">\n    <stop offset="0" stop-color="#f44857" />\n    <stop offset="1" stop-color="#aa212d" />\n  </linearGradient>\n  <linearGradient id="green-bg" y1="0%" y2="100%" x1="0%" x2="0%">\n    <stop offset="0" stop-color="#a5df5d" />\n    <stop offset="1" stop-color="#77bb1e" />\n  </linearGradient>\n  <linearGradient id="brown-bg" y1="0%" y2="100%" x1="0%" x2="0%">\n    <stop offset="0" stop-color="#8b5d46" />\n    <stop offset="1" stop-color="#5b3f33" />\n  </linearGradient>\n</svg>\n<style>\nsvg {\n  font: 10px sans-serif;\n}\nsvg text {\n  color: blue;\n}\n</style>');
          drawXBackground = function() {
            var h, margin, p, w, x, xAxis, xAxisGroup;
            this.chart.selectAll('path').remove();
            w = 380;
            h = 275;
            p = 40;
            margin = 0;
            x = d3.scale.ordinal().domain(['', '20" ago', '10" ago', 'now']).rangePoints([0, w]);
            xAxis = d3.svg.axis().scale(x).tickSize(h - margin * 2).tickPadding(0).ticks(4);
            xAxisGroup = this.chart.append('svg:g').attr('class', 'xTick').call(xAxis);
            return xAxisGroup.selectAll('text').attr('y', 0);
          };
          series = wiki.getData();
          console.log(series);
          data = [];
          for (i = 0, _len = series.length; i < _len; i++) {
            page = series[i];
            level = [];
            color = color_wheel[i % color_wheel.length];
            for (j = 0, _len2 = page.length; j < _len2; j++) {
              p = page[j];
              x = j;
              level.push({
                x: x,
                y: p[1],
                c: "c" + i,
                fill: "fill:url(#" + color + "-bg)"
              });
            }
            data.push(level);
          }
          extent = function(f) {
            var hi, lo, step, _ref;
            _ref = [d3.min(data, f), d3.max(data, f)], lo = _ref[0], hi = _ref[1];
            step = Math.pow(10, Math.floor(Math.log(hi - lo) / Math.log(10)));
            return [step * Math.floor(lo / step), step * Math.ceil(hi / step)];
          };
          w = 380;
          h = 275;
          p = 40;
          this.graph = d3.select(div.get(0)).append('svg:svg').attr("width", w).attr("height", h);
          /*
                  @chart = @graph
                            .append('svg:g')
                              .attr("style", 'background-color:red')
                              .attr("width", w).attr("height", h)
                  drawXBackground()
          */
          stack = d3.layout.stack()(data);
          console.log(stack);
          mx = d3.max(data, function(d) {
            return d.length - 1;
          });
          my = d3.max(data, function(d) {
            return d3.max(d, function(d) {
              return d.y0 + d.y;
            });
          });
          mz = d3.max(data, function(d) {
            return d3.max(d, function(d) {
              return d.y;
            });
          });
          if (mx === 0) mx = 1;
          if (my === 0) my = 1;
          x = function(d) {
            return d.x * w / mx;
          };
          y0 = function(d) {
            return h - d.y0 * h / my;
          };
          y1 = function(d) {
            return h - (d.y + d.y0) * h / my;
          };
          area = d3.svg.area().x(x).y0(y0).y1(y1);
          pathCount = 0;
          this.graph.attr("width", w).attr("height", h);
          this.graph.selectAll('path').remove();
          return this.graph.selectAll('path').data(stack).enter().append('path').attr('class', (function(d) {
            return d[0].c;
          })).attr('style', (function(d) {
            return d[0].fill;
          })).attr('d', area);
        });
      });
    }
  };

}).call(this);
