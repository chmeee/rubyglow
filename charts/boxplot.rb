#!/usr/bin/env ruby

require 'trollop'
require 'chartdirector'
require 'array-statistics'

opts = Trollop::options do
  opt :filename, "output file name, ending in .PNG", :short => "-f", :type => String, :default => "boxplot.png"
  opt :log_scale, "use log scale on y-axis", :short => "-l"
  opt :smaller, "only show the entries with x values smaller than x", :short => "-n", :default => 0.0
  opt :print_labels, "print the labels", :short => "-p"
  opt :title, "chart title", :short => "-t", :type => String
end

labels = Hash.new

STDIN.each do |line|
  line.chomp!
  k,v = line.split(',')
  next if opts[:smaller] > 0 and opts[:smaller] > v.to_i
  labels[k] = labels.has_key?(k) ? labels[k] : Array.new
  labels[k] << v.to_i
end

labels_array = labels.sort

median = labels_array.collect{ |k,v| v.median }
first_q = labels_array.collect{ |k,v| v.percentile(0.25) }
third_q = labels_array.collect{ |k,v| v.percentile(0.75) }
max = labels_array.collect{ |k,v| v.max }
min = labels_array.collect{ |k,v| v.min }

puts labels_array.join('/n') if opts[:print_labels]

c = ChartDirector::XYChart.new(800, 800,0xffffff,-1,-1)
c.swapXY(true)
c.setPlotArea(100, 45, 650, 700, 0xffffff, -1, 0xffffff, ChartDirector::Transparent, ChartDirector::Transparent)
c.addTitle(opts[:title], "arialb.ttf", 14)
c.xAxis().setLabels(labels.keys.sort)
c.yAxis().setLogScale() if opts[:log_scale]
c.xAxis().setColors(ChartDirector::Transparent, 0)
c.addBoxWhiskerLayer(third_q, first_q, max, min, median, 0xAAAAAA, 0x222222).setLineWidth(2)
c.makeChart(opts[:filename])
