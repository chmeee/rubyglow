#!/usr/bin/env ruby

require 'trollop'

opts = Trollop::options do 
  banner <<-EOS

AfterGlow - Random Merge ----------------------------------------------------------------------
      
A tool to merge two files by randomly picking entries from either file and combining them.
If multiple columns are in a file, only the first one will be used.
    
Usage:   ruby random_logs.rb [options] first_file second_file
EOS
  opt :lines, "number of output lines to generate", :short => "-n", :type => :integer, :default => 100
  opt :n_of_first, "number of lines to read from first file", :type => :integer, :short => "-a"
  opt :n_of_second, "number of lines to read from second file", :type => :integer, :short => "-b"
  opt :entropy_one, "bias for first file", :type => :integer, :short => "-q", :default => 1
  opt :entropy_two, "bias for second file", :type => :integer, :short => "-r", :default => 1
end

Trollop::die "need two filenames" if ARGV.length != 2

first_file  = ARGV[0]
second_file = ARGV[1]

first  = Array.new
second = Array.new

File.open(first_file) do |file|
  if opts[:n_of_first] != 0
    file.each_with_index do |line,i|
      first << line.chomp.gsub(/([^,]*).*/,'\1')
      break if i == opts[:n_of_first]
    end
  end
end

File.open(second_file) do |file|
  if opts[:n_of_second] != 0
    file.each_with_index do |line,i|
      second << line.chomp.gsub(/([^,]*).*/,'\1')
      break if i == opts[:n_of_second]
    end
  end
end

opts[:lines].times do
  e1 = ((rand + 0.5) ** opts[:entropy_one]) * first.length
  e1 = first.length - 1 if e1.to_i >= first.length
  e2 = rand ** opts[:entropy_two] * second.length
  puts "#{first[e1.to_i]},#{second[e2.to_i]}"
end

