(function(Modules, d3) {
  "use strict";

  // Colours in RGB for the bubbles.
  var highRGB= [247, 157, 0],
      lowRGB = [100, 243, 140],
      zeroRGB = [100, 243, 255];

  function initialiseSVG(svgElement, data) {
    var svg = d3.select(svgElement),
        diameter = 1000, // This should be the width and height of the viewBox
        g = svg.append("g").attr("transform", "translate(2,2)"),
        format = d3.format(",d");

    var pack = d3.pack()
        .size([diameter - 4, diameter - 4]);

    var root = d3
      .hierarchy(data)
      .sum(function(d) { return d.size; })
      .sort(function(a, b) { return b.value - a.value; });

    var node = g
        .selectAll(".node")
        .data(pack(root).descendants())
        .enter()
        .append("g")
        .attr("transform", function(d) {
          return "translate(" + d.x + "," + d.y + ")";
        });

    node.append("title")
      .text(function(d) { return d.data.name + "\n" + format(d.data.size); });

    node.append("circle")
      .attr("class", "bubbles-circle")
      .attr("r", function(d) { return d.r; });

    node.filter(function(d) { return !d.children; })
      .append("text")
      .attr("class", "bubbles-text")
      .attr("dy", "0.3em")
      .text(function(d) { return d.data.name.substring(0, d.r / 3); });

    return node;
  }

  function rgbForNode(d, maxSize) {
    function rgbInterpolate(start, end, value) {
      var result = [];
      for (var i=0; i<3; i++) {
        result[i] = start[i] + ((end[i] - start[i]) * value);
      }
      return result;
    }

    var highRGB= [247, 157, 0];
    var lowRGB = [100, 243, 140];
    var zeroRGB = [100, 243, 255];

    if (d.data.size === 0) {
      return zeroRGB;
    } else {
      return rgbInterpolate(lowRGB, highRGB, (d.data.size / maxSize));
    }
  }

  function render(node, maxSize, lowerSizeBound, upperSizeBound) {
    function rgbArrayToFill(rgb) {
      return "fill: rgb(" + rgb[0] + ", " + rgb[1] + ", " + rgb[2] + ");";
    }

    node.attr("style", function(d) {
      return rgbArrayToFill(rgbForNode(d, maxSize));
    });

    node.attr("display", function(d) {
      var size_in_bounds = ((d.data.size >= lowerSizeBound) &&
                            (d.data.size < upperSizeBound));
      return size_in_bounds ? "block" : "none";
    });
  }

  function startVisualisation(svgElement, data) {
    var node = initialiseSVG(svgElement, data);

    var maxSize = 0;
    node.each(function(d) {
      maxSize = Math.max(maxSize, d.data.size);
    });

    var lowerBoundInput = $("#lower_bound_range_input");
    var upperBoundInput = $("#upper_bound_range_input");
    var lowerBoundLabel = $("#lower_bound_label");
    var upperBoundLabel = $("#upper_bound_label");

    lowerBoundInput.val(0);
    lowerBoundInput.attr("max", maxSize + 1);
    upperBoundInput.val(maxSize + 1);
    upperBoundInput.attr("max", maxSize + 1);

    lowerBoundInput.removeClass("hidden");
    upperBoundInput.removeClass("hidden");

    var update = function() {
      var lowerBound = parseInt(lowerBoundInput.val(), 10);
      var upperBound = parseInt(upperBoundInput.val(), 10);

      lowerBoundLabel.text(lowerBound + " or more tagged items");
      upperBoundLabel.text("Less than " + upperBound + " tagged items");

      render(node, maxSize, lowerBound, upperBound);
    };

    update();

    lowerBoundInput.on("input", update);
    upperBoundInput.on("input", update);
  }

  Modules.BubblesVisualisation = function() {
    this.start = function(svgElement) {
      var dataURL = svgElement[0].getAttribute("data-url");

      d3.json(dataURL, function(error, data) {
        if (error) throw error;

        startVisualisation(svgElement[0], data);

        $("#loading-notification").hide();
      });
    };
  };

})(window.GOVUKAdmin.Modules, window.d3);
