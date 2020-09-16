const margin = { top: 20, right: 20, bottom: 20, left: 40 };

function showChart(jsonFile) {
  d3.json(jsonFile).then((data) => {
    // flatten generations
    data = data.flat();

    // code for finding ancestors
    const fatherMap = {};
    data.forEach((d) => {
      if (d.father != null) {
        const father = lookup(data, d.father.id);
        if (father != null) {
          fatherMap[d.id] = father;
        }
      }
    });
    const motherMap = {};
    data.forEach((d) => {
      if (d.mother != null) {
        const mother = lookup(data, d.mother.id);
        if (mother != null) {
          motherMap[d.id] = mother;
        }
      }
    });

    function getAncestors(id) {
      const ancestors = [];
      const father = fatherMap[id];
      const mother = motherMap[id];
      if (father) {
        ancestors.push(father.id);
        ancestors.push(...getAncestors(father.id));
      }
      if (mother) {
        ancestors.push(mother.id);
        ancestors.push(...getAncestors(mother.id));
      }
      return ancestors;
    }

    // only show people that have an age value
    data = data.filter((d) => d.age != null);

    function genderColour(person) {
      if (person.gender === "M") {
        return "orange";
      } else if (person.gender === "F") {
        return "green";
      } else {
        return "grey";
      }
    }

    const yearSpan = 2020 - d3.min(data, (d) => getYear(d.birth_date));
    const maxAge = d3.max(data, (d) => d.age);

    const width = yearSpan * 1.5;
    const height = maxAge * 1.5;
    const svg = d3
      .select("body")
      .append("svg")
      .attr(
        "viewBox",
        `0 0 ${width + margin.left + margin.right} ${
          height + margin.top + margin.bottom
        }`
      );

    const xScale = d3
      .scaleLinear()
      .domain([d3.min(data, (d) => getYear(d.birth_date)), 2020])
      .range([0, width]);

    const yScale = d3.scaleLinear().domain([0, maxAge]).range([height, 0]);

    const g = svg
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    const tip = d3
      .tip()
      .attr("class", "d3-tip")
      .direction((d) => (getYear(d.birth_date) < 1900 ? "n" : "nw"))
      .html(
        (d) =>
          `${d.name}<br/>${d.birth_date_raw}-${d.death_date_raw || ""}<br/>${
            d.age == null ? "" : "Age " + d.age
          }`
      );
    svg.call(tip);

    g.selectAll("people")
      .data(data)
      .enter()
      .append("line")
      .attr("class", "person-line")
      .attr("id", (d) => `person-${d.id}-line`)
      .attr("x1", (d) => xScale(getYear(d.birth_date)))
      .attr("y1", (d) => yScale(0))
      .attr("x2", (d) => xScale(getYear(d.death_date)))
      .attr("y2", (d) => yScale(d.age))
      .attr("stroke", (d) => genderColour(d))
      .attr("stroke-width", 0.75)
      .attr("stroke-opacity", 0.5);

    g.selectAll("people")
      .data(data)
      .enter()
      .append("circle")
      .attr("class", "person-circle")
      .attr("id", (d) => `person-${d.id}-circle`)
      .attr("cx", (d) => xScale(getYear(d.death_date)))
      .attr("cy", (d) => yScale(d.age))
      .attr("r", 2)
      .attr("fill", (d) => genderColour(d))
      .attr("stroke", "white")
      .attr("stroke-width", 0.3)
      .on("mouseover", (data, index, element) => {
        const ancestors = getAncestors(data.id);
        ancestors.push(data.id);
        svg
          .selectAll(".person-circle")
          .attr("fill-opacity", (d) => (ancestors.includes(d.id) ? 1 : 0.1));
        svg
          .selectAll(".person-line")
          .attr("stroke-opacity", (d) => (ancestors.includes(d.id) ? 1 : 0.1));
        tip.show(data, element[index]);
      })
      .on("mouseout", (data, index, element) => {
        svg.selectAll(".person-circle").attr("fill-opacity", 1);
        svg.selectAll(".person-line").attr("stroke-opacity", 1);
        tip.hide(data, element[index]);
      });

    // Draw x axis
    const xAxis = d3.axisBottom().scale(xScale).tickFormat(d3.format("d"));
    svg
      .append("g")
      .attr("class", "axis")
      .attr(
        "transform",
        "translate(" + margin.left + "," + (margin.top + height) + ")"
      )
      .call(xAxis);

    // Draw y axes
    const yAxisLeft = d3.axisLeft().scale(yScale);
    svg
      .append("g")
      .attr("class", "axis")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
      .call(yAxisLeft);

    svg
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", margin.left - 40)
      .attr("x", height / 2 - 150)
      .attr("dy", "1em")
      .style("text-anchor", "middle")
      .attr("font-family", "sans-serif")
      .attr("font-size", "10pt")
      .text("Age");

    // Add title, captions, etc
    d3.select("svg")
      .append("g")
      .append("text")
      .attr("x", margin.left + 5)
      .attr("y", margin.top / 2)
      .attr("font-family", "sans-serif")
      .attr("font-size", "14pt")
      .attr("dominant-baseline", "baseline")
      .text("Family lines");

    d3.select("svg")
      .append("g")
      .append("text")
      .attr("x", margin.left + width + 5)
      .attr("y", margin.top + height + margin.bottom + 10)
      .attr("font-family", "sans-serif")
      .attr("font-size", "6pt")
      .attr("text-anchor", "end")
      .attr("dominant-baseline", "middle")
      .text("Graphic: Tom White. Data source: Eliane Wigzell");

    d3.select("svg")
      .append("g")
      .append("circle")
      .attr("cx", margin.left + 10)
      .attr("cy", margin.top)
      .attr("r", 2)
      .attr("fill", genderColour({ gender: "F" }))
      .attr("stroke", "white")
      .attr("stroke-width", 0.3);
    d3.select("svg")
      .append("g")
      .append("text")
      .attr("x", margin.left + 15)
      .attr("y", margin.top)
      .attr("font-family", "sans-serif")
      .attr("font-size", "6pt")
      .attr("dominant-baseline", "middle")
      .text("Female");

    d3.select("svg")
      .append("g")
      .append("circle")
      .attr("cx", margin.left + 10)
      .attr("cy", margin.top + 10)
      .attr("r", 2)
      .attr("fill", genderColour({ gender: "M" }))
      .attr("stroke", "white")
      .attr("stroke-width", 0.3);
    d3.select("svg")
      .append("g")
      .append("text")
      .attr("x", margin.left + 15)
      .attr("y", margin.top + 10)
      .attr("font-family", "sans-serif")
      .attr("font-size", "6pt")
      .attr("dominant-baseline", "middle")
      .text("Male");
  });
}
function getYear(date) {
  if (date == null) {
    return "2020";
  }
  return date.substring(0, 4);
}
function lookup(data, id) {
  for (let person of data) {
    if (person.id === id) {
      return person;
    }
  }
  return null;
}
