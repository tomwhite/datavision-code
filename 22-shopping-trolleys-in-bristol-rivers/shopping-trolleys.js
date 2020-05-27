const count = 10;
const size = 25;
const w = 450;

d3.csv("data/edp-trolleys-clean.csv").then(function (data) {
  const years = ["2005", "2007", "2008", "2009", "2010", "2011"];
  const trolleyCounts = years.map((year) => ({
    year: year,
    trolleyCounts: d3.sum(data, (d) => d[year]),
    img: "shopping-trolley.png",
  }));

  const isoData = [];
  trolleyCounts.forEach(function (d) {
    for (let i = 0; i < d.trolleyCounts / count - 1; i++) {
      isoData.push({ year: d.year, value: 1, img: d.img });
    }
  });

  const max = d3.max(trolleyCounts, (d) => d.trolleyCounts);

  const plot = {
    $schema: "https://vega.github.io/schema/vega/v4.json",
    title: "Abandoned Shopping Trolleys in Bristol rivers",
    description: "Data: Bristol City Council",
    width: w,
    height: 400,
    data: [
      {
        name: "trolleyCounts",
        values: isoData,
        transform: [
          {
            type: "stack",
            field: "value",
            groupby: ["year"],
          },
        ],
      },
    ],
    scales: [
      {
        name: "xscale",
        type: "band",
        domain: { data: "trolleyCounts", field: "year" },
        range: "width",
      },
      {
        name: "yscale",
        type: "linear",
        domain: { data: "trolleyCounts", field: "y1" },
        range: "height",
      },
      {
        name: "ynumscale",
        type: "linear",
        domain: [0, max],
        range: "height",
      },
    ],

    axes: [
      {
        orient: "bottom",
        scale: "xscale",
        labelFontSize: 14,
      },
      {
        orient: "left",
        scale: "ynumscale",
        labelFontSize: 14,
        title: "Trolleys found",
      },
    ],

    marks: [
      {
        type: "image",
        from: { data: "trolleyCounts" },
        encode: {
          enter: {
            height: { value: size },
            width: { value: size },
            x: { scale: "xscale", field: "year", offset: 25 },
            y: { scale: "yscale", field: "y0" },
            url: { field: "img" },
            baseline: { value: "bottom" },
            align: { value: "left" },
          },
        },
      },
    ],
  };
  vegaEmbed("#plot", plot);
});
