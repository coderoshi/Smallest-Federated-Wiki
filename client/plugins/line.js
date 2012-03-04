(function() {

  window.plugins.line = {
    bind: function(div, item) {},
    emit: function(div, item) {
      return wiki.getScript('/js/d3/d3.js', function() {
        var data, extent, h, p, rules, series, start, vis, w, x, y;
        div.append('<style>\nsvg {\n  font: 10px sans-serif;\n}\n\n.rule line {\n  stroke: #eee;\n  shape-rendering: crispEdges;\n}\n\n.rule line.axis {\n  stroke: #000;\n}\n\n.line {\n  fill: none;\n  stroke: steelblue;\n  stroke-width: 1.5px;\n}\n\ncircle.line {\n  fill: #fff;\n}\n</style>');
        series = wiki.getData()[0];
        console.log(series);
        data = (start = series[0][0]) > 1000000000000 ? (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = series.length; _i < _len; _i++) {
            p = series[_i];
            _results.push({
              x: (p[0] - start) / 24 / 3600 / 1000,
              y: p[1]
            });
          }
          return _results;
        })() : start > 1000000000 ? (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = series.length; _i < _len; _i++) {
            p = series[_i];
            _results.push({
              x: (p[0] - start) / 24 / 3600,
              y: p[1]
            });
          }
          return _results;
        })() : (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = series.length; _i < _len; _i++) {
            p = series[_i];
            _results.push({
              x: new Date(p.Date),
              y: p.Price * 1
            });
          }
          return _results;
        })();
        w = 380;
        h = 275;
        p = 40;
        extent = function(f) {
          var hi, lo, step, _ref;
          _ref = [d3.min(data, f), d3.max(data, f)], lo = _ref[0], hi = _ref[1];
          step = Math.pow(10, Math.floor(Math.log(hi - lo) / Math.log(10)));
          return [step * Math.floor(lo / step), step * Math.ceil(hi / step)];
        };
        x = d3.time.scale().domain(extent(function(p) {
          return p.x;
        })).range([0, w]);
        y = d3.scale.linear().domain(extent(function(p) {
          return p.y;
        })).range([h, 0]);
        vis = d3.select(div.get(0)).data([data]).append("svg").attr("width", w + p * 2).attr("height", h + p * 2).append("g").attr("transform", "translate(" + p + "," + p + ")");
        rules = vis.selectAll("g.rule").data(x.ticks(10)).enter().append("g").attr("class", "rule");
        rules.append("line").attr("x1", x).attr("x2", x).attr("y1", 0).attr("y2", h - 1);
        rules.append("line").attr("class", function(d) {
          return d != null ? d : {
            "null": "axis"
          };
        }).attr("y1", y).attr("y2", y).attr("x1", 0).attr("x2", w + 1);
        rules.append("text").attr("x", x).attr("y", h + 3).attr("dy", ".71em").attr("text-anchor", "middle").text(x.tickFormat(10));
        rules.append("text").attr("y", y).attr("x", -3).attr("dy", ".35em").attr("text-anchor", "end").text(y.tickFormat(10));
        vis.append("path").attr("class", "line").attr("d", d3.svg.line().x(function(d) {
          return x(d.x);
        }).y(function(d) {
          return y(d.y);
        }));
        return vis.selectAll("circle.line").data(data).enter().append("circle").attr("class", "line").attr("cx", function(d) {
          return x(d.x);
        }).attr("cy", function(d) {
          return y(d.y);
        }).attr("r", 3.5).on('mouseover', function() {
          return d3.select(this).attr('r', 8);
        }).on('mouseout', function() {
          return d3.select(this).attr('r', 3.5);
        }).on('click', function(d, i) {
          return console.log(d, i);
        });
      });
    }
  };

}).call(this);
