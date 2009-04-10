#!/usr/bin/env ruby

# Usage:	ragator -r file.argus -nn -A -s +dur -s +sttl -s +dttl | ./argus2csv.pl ["field list"]

output = ARGV[0] || "full"
DEBUG  = true

STDIN.each do |input|
  fields = Hash.new
  input.chomp!
  if input =~ /^(\d+ \S+ \d+ \d+:\d+:\d+|\d+-\d+-\d+ \d+:\d+:\d+.\d+) \s*(.*?)(?:\s*(\S+))? \s*(\d+\.\d+\.\d+\.\d+)(?:.(\d+))? \s*(\S+)\s* (\d+\.\d+\.\d+\.\d+)(?:.(\d+))?\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\S+)\s*(\S+)\s*(\d+)\s*(\d+)/
    fields[:timestamp] = $1
    fields[:foo]       = $2
    fields[:proto]     = $3
    fields[:sip]       = $4
    fields[:sport]     = $5 || ""
    fields[:dir]       = $6
    fields[:dip]       = $7
    fields[:dport]     = $8 || ""
    fields[:spkts]     = $9
    fields[:dpkts]     = $10
    fields[:sbytes]    = $11
    fields[:dbytes]    = $12
    fields[:status]    = $13
    fields[:duration]  = $14
    fields[:sttl]      = $15
    fields[:dttl]      = $16
  elsif input =~ /^(\d+ \S+ \d+ \d+:\d+:\d+|\d+-\d+-\d+ \d+:\d+:\d+.\d+) \s*(.*?)(?:\s*(\S+))? \s*(\S+:\S+:\S+:\S+:\S+:\S+)(?: \s*(\S+))? \s*(\S+)\s* (\S+:\S+:\S+:\S+:\S+:\S+) \s*(\S+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\S+)\s*(\S+)\s*(\d+)\s*(\d+)/
    fields[:timestamp] = $1
    fields[:foo]       = $2
    fields[:proto]     = $3
    fields[:smac]      = $4
    fields[:dir]       = $6
    fields[:dmac]      = $7
    fields[:spkts]     = $9
    fields[:dpkts]     = $10
    fields[:sbytes]    = $11
    fields[:dbytes]    = $12
    fields[:status]    = $13
    fields[:duration]  = $14
    fields[:sttl]      = $15
    fields[:dttl]      = $16
  else
    STDERR.puts "Error: #{input}" if DEBUG
    next
  end

  if output == "full"
    puts fields.values_a(:timestamp, :sip, :dip, :sport, :dport, :proto, :sttl, :dttl).join(",")
  else
    tokens = output.split(" ").map{|e| e.to_sym}
    tokens.each { |token| STDERR.puts "Error: #{token} is not a known field" unless fields.has_key?(token) }
    puts fields.values_at(*tokens).compact.join(",")
  end

end
