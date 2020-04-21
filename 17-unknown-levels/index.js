// Read data from verbose Tidepool format and convert to a CSV with only required fields

const createCsvWriter = require("csv-writer").createObjectCsvWriter;
const fs = require("fs");
const moment = require("moment");

const data = fs.readFileSync("data/out.json");
const start = moment("2019-01-01", "YYYYMMDD");
const end = moment("2020-01-01", "YYYYMMDD");

const dataset = JSON.parse(data)
  .filter((v) => v.type == "cbg")
  .filter((v) => moment(v.time).isBetween(start, end))
  .map((v) => ({
    ts: moment(v.time).toDate(),
    date: moment(v.time).startOf("day").format("YYYY-MM-DD"),
    minOfDay: moment(v.time).diff(moment(v.time).startOf("day"), "minutes"),
    bg: v.value,
    type: v.type,
  }))
  .sort((a, b) => a.ts - b.ts);

const csvWriter = createCsvWriter({
  path: "data/bgs.csv",
  header: [
    { id: "date", title: "date" },
    { id: "minOfDay", title: "minOfDay" },
    { id: "bg", title: "bg" },
  ],
});

csvWriter.writeRecords(dataset).then(() => {});
