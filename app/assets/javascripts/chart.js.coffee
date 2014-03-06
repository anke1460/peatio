organizeData = (json) ->
  priceData = []
  amountData = []
  for i in json
    priceData.push  {x: i.date * 1000, y: i.amount}
    amountData.push {x: i.date * 1000, y: i.price}

  data = [
    {
      "key": "交易量",
      "bar": true,
      "values": priceData
    },
    {
      "key": "价格",
      "values": amountData
    }
  ]

nv.addGraph ->
  d3.json "/api/trades/cnybtc?hours=24", (error, json) ->
    data = organizeData(json)
    chart = nv.models.linePlusBarChart().margin
      top: 30
      right: 80
      bottom: 50
      left: 70
    .x((d, i) -> i
    ).color(d3.scale.category10().range())

    chart.xAxis.tickFormat((d) ->
      dx = data[0].values[d] and data[0].values[d].x or 0
      (if dx then d3.time.format("%H:%M %p")(new Date(dx)) else "")
    ).showMaxMin false

    chart.y1Axis.tickFormat d3.format(",f")
    chart.y2Axis.tickFormat (d) -> "CNY " + d3.format(",.2f")(d)
    chart.bars.forceY([0]).padData false

    d3.select("#nvchart svg").datum(data).transition().duration(500).call chart
    nv.utils.windowResize chart.update
