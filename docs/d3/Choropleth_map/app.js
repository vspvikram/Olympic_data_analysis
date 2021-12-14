
// The svg
var svg = d3.select("svg"),
  width = +svg.attr("width"),
  height = +svg.attr("height");

// Map and projection
var path = d3.geoPath();
var projection = d3.geoMercator()
  .scale(70)
  .center([0,20])
  .translate([width / 2, height / 2]);

// Data and color scale
var data = new Map();
var colorScale = d3.scaleThreshold()
  .domain([0, 2, 7, 10, 25, 50, 80, 100])
  .range(d3.schemeOranges[8]);

const allGroup = ["Gold", "Silver", "Bronze"]

// add the options to the button
d3.select("#selectButton1")
  .selectAll('myOptions')
    .data(allGroup)
  .enter()
  .append('option')
  .text(function (d) { return d; }) // text showed in the menu
  .attr("value", function (d) { return d; }) // corresponding value returned by the button

      // When the button is changed, run the updateChart function
d3.select("#selectButton1").on("change", function(event,d) {
  // recover the option that has been chosen
  const selectedOption = d3.select(this).property("value")
  // run the updateChart function with this selected option
  console.log(selectedOption);
  plot_graph(medal_type = selectedOption);
})

const plot_graph = (medal_type = "Gold") => {

Promise.all([
  d3.json("https://raw.githubusercontent.com/holtzy/D3-graph-gallery/master/DATA/world.geojson"),
  d3.csv("https://raw.githubusercontent.com/vspvikram/Olympic_data_analysis/main/Data/data_by_medals_country_avg.csv", function(d) { 
    if (d.medal == medal_type) {
      data.set(d.name, {avg_medals: d.avg_medals, medal: d.medal, country: d.country});
    }
  })]).then(function(loadData){
      let topo = loadData[0];
      // List of groups (here I have one group per column)
  
      let Tooltip = d3.select("#my_dataviz2")
                      .append("div")
                      .attr("class", "tooltip")
                      .style("visibility", "hidden")
                      .style("position", "absolute")
                      .style("background-color", "white")
                      .style("border", "solid")
                      .style("border-width", "2px")
                      .style("border-radius", "5px")
                      .style("padding", "5px");
  
      let mouseOver = function(d) {
        d3.selectAll(".Country")
          .transition()
          .duration(200)
          .style("opacity", .5)
        d3.select(this)
          .transition()
          .duration(200)
          .style("opacity", 1)
          .style("stroke", "black");
        Tooltip.style("visibility",  "visible");
    }
  
    let mouseMove = function(event, data) {
      if(data.total.avg_medals === undefined) {
        Tooltip
          .html("Country: " + data.properties.name + "<br>" + "Average Medals: " + "0")
          .style("left", (d3.pointer(event)[0]+10) + "px")
          .style("top", (d3.pointer(event)[1]) + "px");
      } else {
        Tooltip
            .html("Country: " + data.properties.name + "<br>" + "Average Medals: " + data.total.avg_medals)
            .style("left", (d3.pointer(event)[0]+10) + "px")
            .style("top", (d3.pointer(event)[1]) + "px");
      }
    }
  
    let mouseLeave = function(d) {
      d3.selectAll(".Country")
        .transition()
        .duration(200)
        .style("opacity", .8)
      d3.select(this)
        .transition()
        .duration(200)
        .style("stroke", "none");
        Tooltip.style("visibility", "hidden");
    }
    // Draw the map
    svg.append("g")
      .selectAll("path")
      .data(topo.features)
      .enter()
      .append("path")
        // draw each country
        .attr("d", d3.geoPath()
          .projection(projection)
        )
        // set the color of each country
        .attr("fill", function (d) {
          d.total = data.get(d.id) || 0;
          return colorScale(d.total);
        })
        .style("stroke", "transparent")
        .attr("class", function(d){ return "Country" } )
        .style("opacity", .8)
        .on("mouseover", mouseOver )
        .on("mousemove", mouseMove )
        .on("mouseleave", mouseLeave )
  
  })
}

plot_graph();