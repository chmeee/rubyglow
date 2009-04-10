#!/usr/bin/env ruby

require 'trollop'
require 'chartdirector'
require 'array-statistics'

opts = Trollop::options do
  opt :filename, "output file name, ending in .PNG", :short => "-f", :type => String, :default => "bar.png"
  opt :print_labels, "print the labels", :short => "-p"
  opt :title, "chart title", :short => "-t", :type => String, :default => "Bar chart"
  opt :top_n, "only show the top N entries", :short => "-n", :default => 0
end

uniq = Hash.new

STDIN.each do |line|
  line.chomp!
  uniq[line] = 0 unless uniq[line]
  uniq[line] += 1
end

two_d = Array.new
uniq.each { |k,v| two_d << [k,v] }

two_d.sort!{ |a,b| a[1] <=> b[1] }.reverse!

if opts[:top_n] and opts[:top_n]>0
  two_d = two_d[0,opts[:top_n]]
end

data = two_d.map{ |e| e[1] }
labels = two_d.map{ |e| e[0] }

puts labels.join('/n') if opts[:print_labels]

c = ChartDirector::XYChart.new(800, 800,0xffffff,-1,-1)
c.swapXY(true)
c.setPlotArea(100, 45, 650, 700, 0xffffff, -1, 0xffffff, ChartDirector::Transparent, ChartDirector::Transparent)
c.addTitle(opts[:title], "arialb.ttf", 14)
c.xAxis().setLabels(labels)
c.xAxis().setColors(ChartDirector::Transparent, 0)

layer = c.addBarLayer(data, 0x888888)
layer.setBorderColor(ChartDirector::Transparent)
layer.setBarGap(0.1)

c.makeChart(opts[:filename])
