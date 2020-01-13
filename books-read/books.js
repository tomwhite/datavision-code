function parseDate(str) {
  const dt = d3.timeParse("%d/%m/%y")(str); // try two-digit year first ('19')
  return dt != null ? dt : d3.timeParse("%d/%m/%Y")(str); // then try four digit year ('2019')
}

const fictionColor = "blue";
const nonFictionColor = "green";

// set the dimensions and margins of the graph
const margin = { top: 10, right: 30, bottom: 30, left: 60 },
  width = 1000 - margin.left - margin.right,
  height = 550 - margin.top - margin.bottom;

// append the svg object to the body of the page
const svg = d3
  .select("#my_dataviz")
  .append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

// read the data from a CSV file
d3.csv("data/2019_reading.csv", function(d) {
  return {
    title: d.title,
    author: d.author,
    pages: +d.pages,
    dateStarted: parseDate(d["date started"]),
    dateFinished: d3.timeDay.offset(parseDate(d["date finished"]), 1), // assume finish reading at end of day
    fiction: d["fiction/non-fiction"]
  };
}).then(function(data) {
  data[0].pagesCumulative = data[0].pages;
  for (let i = 1; i < data.length; i++) {
    data[i].pagesCumulative = data[i - 1].pagesCumulative + data[i].pages;
  }

  data.forEach(elt => (elt.dateStartedMillis = elt.dateStarted.getTime()));
  data.forEach(elt => (elt.dateFinishedMillis = elt.dateFinished.getTime()));

  // x axis
  const x = d3
    .scaleTime()
    .domain(d3.extent(data, d => d.dateStarted))
    .range([0, width]);
  svg
    .append("g")
    .attr("transform", "translate(0," + height + ")")
    .call(d3.axisBottom(x));

  // y -axis
  const y = d3
    .scaleLinear()
    .domain([0, d3.max(data, d => d.pagesCumulative)])
    .range([height, 0]);
  svg.append("g").call(d3.axisLeft(y));

  svg
    .append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 0 - margin.left)
    .attr("x", 0 - height / 2)
    .attr("dy", "1em")
    .style("text-anchor", "middle")
    .text("Pages read (cumulative)");

  const midYear = new Date("2019-07-01T00:00:00");

  // book tooltips
  const tip = d3
    .tip()
    .attr("class", "d3-tip")
    .offset(d => (d.dateStarted < midYear ? [0, 10] : [0, -10]))
    .direction(d => (d.dateStarted < midYear ? "e" : "w"))
    .html(function(d, i) {
      const bookNumber = i + 1;
      const durationDays = d3.timeDay.count(d.dateStarted, d.dateFinished);
      const dayStr = durationDays == 1 ? "day" : "days";
      const pagesPerDay = d3.format(".0f")(d.pages / durationDays);
      return `${bookNumber}. <i>${d.title}</i> by ${d.author}</br>${d.pages} pages, ${durationDays} ${dayStr}, ${pagesPerDay} pages/day`;
    });
  svg.call(tip);

  // draw books as rectangles
  svg
    .selectAll("things")
    .data(data)
    .enter()
    .append("rect")
    .attr("x", d => x(d.dateStartedMillis))
    .attr("y", d => y(d.pagesCumulative))
    .attr("width", d => x(d.dateFinishedMillis) - x(d.dateStartedMillis))
    .attr("height", d => y(d.pagesCumulative - d.pages) - y(d.pagesCumulative))
    .style("fill-opacity", 0.2)
    .style("fill", d =>
      d.fiction === "fiction" ? fictionColor : nonFictionColor
    );

  // invisible rectangles to increase the hit area for tooltips for the very small books
  svg
    .selectAll("things")
    .data(data)
    .enter()
    .append("rect")
    .attr("x", d => x(d.dateStartedMillis))
    .attr("y", d => y(d.pagesCumulative))
    .attr("width", d =>
      Math.max(x(d.dateFinishedMillis) - x(d.dateStartedMillis), 5)
    )
    .attr("height", d =>
      Math.max(y(d.pagesCumulative - d.pages) - y(d.pagesCumulative), 5)
    )
    .attr("visibility", "hidden")
    .attr("pointer-events", "all")
    .on("mouseover", tip.show)
    .on("mouseout", tip.hide);

  // add a slope line to show the reading speed
  svg
    .selectAll("things")
    .data(data)
    .enter()
    .append("line")
    .attr("x1", d => x(d.dateStartedMillis))
    .attr("y1", d => y(d.pagesCumulative - d.pages))
    .attr("x2", d => x(d.dateFinishedMillis))
    .attr("y2", d => y(d.pagesCumulative))
    .attr("stroke", "black")
    .attr("stroke-width", 0.5)
    .attr("opacity", 0.5);

  // add summary lines and statistics for fiction vs non-fiction books

  function summary(type) {
    const startMillis =
      data[0].dateStartedMillis + 4.5 * 30 * 24 * 60 * 60 * 1000; // offset to avoid overlap

    const booksFiltered = data.filter(book => book.fiction === type);

    const numPages = booksFiltered.reduce(
      (prev, cur, i) => prev + cur.pages,
      0
    );

    const durationMillis = booksFiltered.reduce(
      (prev, cur, i) => prev + cur.dateFinishedMillis - cur.dateStartedMillis,
      0
    );

    const durationDays = booksFiltered.reduce(
      (prev, cur, i) =>
        prev + d3.timeDay.count(cur.dateStarted, cur.dateFinished),
      0
    );

    const pagesPerDay = d3.format(".0f")(numPages / durationDays);

    svg
      .selectAll("things")
      .data([
        {
          numPages: numPages,
          durationMillis: durationMillis
        }
      ])
      .enter()
      .append("line")
      .attr("x1", x(startMillis))
      .attr("y1", y(0))
      .attr("x2", d => x(startMillis + d.durationMillis))
      .attr("y2", d => y(d.numPages))
      .attr("stroke", type === "fiction" ? fictionColor : nonFictionColor)
      .attr("stroke-width", 1)
      .attr("opacity", 0.5);

    const capitalizedType = type.charAt(0).toUpperCase() + type.slice(1);
    svg
      .append("text")
      .attr("x", x(startMillis + durationMillis))
      .attr("y", y(numPages) - 10)
      .attr("text-anchor", "middle")
      .style("font-size", "12px")
      .text(
        `${capitalizedType}: ${d3.format(",")(
          numPages
        )} pages, ${durationDays} days, ${pagesPerDay} pages/day`
      );
  }

  summary("fiction");
  summary("non-fiction");

  svg
    .append("text")
    .attr("x", width / 2)
    .attr("y", margin.top / 2)
    .attr("text-anchor", "middle")
    .style("font-size", "20px")
    .text("Books read by Emilia White in 2019");
});
