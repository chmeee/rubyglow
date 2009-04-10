#!/usr/bin/env ruby

require 'trollop'

opts = Trollop::options do 
  banner <<-EOS

AfterGlow - Log Merge ----------------------------------------------------------------------
      
A tool to merge two files by using the first file as the lookup table. If entries show up in 
the second file, the lookup table is used to add an extra column with the 'value'

Usage:   ruby merge_logs.rb [options] lookup file

EOS
  opt :overwrite, "overwrites the entry which was looked up instead of appending it as a separate column", :short => "-o"
end

Trollop::die "need two filenames" if ARGV.length != 2

lookup_file = ARGV[0]
dest_file   = ARGV[1]

lookup = Array.new
lookup_table = Hash.new

File.open(lookup_file) do |file|
  file.each do |line|
    line.chomp!
    junks = line.split(",")
    lookup_table[junks[0]] = junks[1]
  end
end

File.open(dest_file) do |file|
  file.each do |line|
    line.chomp!
    junks = line.split(",")

    if opts[:overwrite]
      junks.map!{|e| lookup_table[e] || e }
    else
      junks += junks.find_all{|e| lookup_table[e] }.map{|e| lookup_table[e] }
    end

    puts junks.join(",")
  end
end

