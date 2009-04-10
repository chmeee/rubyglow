#!/usr/bin/env ruby

require 'trollop'
require 'chartdirector'

opts = Trollop::options do
  opt :filename, "output file name, ending in .PNG", :short => "-f", :type => String, :default => "trend.png"
  opt :log_scale, "use log scale on y-axis", :short => "-l"
  opt :print_labels, "print the labels", :short => "-p"
  opt :title, "chart title", :short => "-t", :type => String, :default => "Trendline"
  opt :bar, "use a bar chart instead of a line chart", :short => "-b"
  opt :trend_line, "show trend line", :short => "-a"
  opt :series_label, "show series label", :short => "-s"
end

labels = Array.new
series = Array.new

STDIN.each do |line|
  line.chomp!
  input = line.split(',')
  labels << input.shift

  input.each_with_index do |item, i|
    series[i] = series[i].nil? ? Array.new : series[i]
    series[i] << item.to_i
  end
end

puts labels.join('/n') if opts[:print_labels]

c = ChartDirector::XYChart.new(600, 300)
c.setPlotArea(45, 45, 500, 200, 0xffffff, -1, 0xffffff, ChartDirector::Transparent, ChartDirector::Transparent)
c.addTitle(opts[:title], "arialb.ttf", 14)
c.xAxis().setWidth(1)
c.yAxis().setWidth(1)
c.xAxis().setLabels(labels)
c.yAxis().setLogScale() if opts[:log_scale]
c.addLegend(50, 30, false, "arialbd.ttf", 9).setBackground(ChartDirector::Transparent)

if opts[:bar]
  layer = c.addBarLayer()
  layer.setBorderColor(ChartDirector::Transparent)
  layer.setBarGap(0.1)
else
  layer = c.addLineLayer()
  layer.setLineWidth(1)
end

series.each_with_index do |data, i|
  if opts[:series_label]
    label = "Line #{i}"
    trend = "Trend #{i}"
  end
  layer.addDataSet(data, 0xcccccc, label).setDataSymbol(ChartDirector::SquareSymbol, 7)
  if opts[:trend_line]
    c.addTrendLayer(data, 0xcccccc, trend).setLineWidth(1)    
  end
end

c.makeChart(opts[:filename])
