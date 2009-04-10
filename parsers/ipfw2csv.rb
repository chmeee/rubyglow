#!/usr/bin/env ruby

# Usage:	cat /var/log/ipfw.log | ./ipfw2csv.pl ["field list"]

output  = ARGV[0] || "full"
DEBUG   = true
reverse = false

STDIN.each do |input|
  input.chomp!
  keys = [:timestamp, :rulenumber, :action, :proto, :dip, :dport, :sip, :sport, :direction, :interface, :rest]
  values = input.match(/^(.* \d{2}:\d{2}:\d{2}).*? (\d+) (Deny|Allow) (UDP|TCP) ([^:]*):(\d+) ([^:]*):(\d+) (in|out) via ([^\s]+)(.*)/)

  if values.nil?
    keys = [:timestamp, :action, :proto, :sip, :sport, :dip, :dport,:rest]
    values = input.match(/^(.* \d{2}:\d{2}:\d{2}).*? Stealth Mode connection (attempt) to (UDP|TCP) ([^:]*):(\d+) from ([^:]*):(\d+)(.*)/)
  end

  if values.nil?
    keys = [:timestamp, :rulenumber, :action, :proto, :app,:sip, :dip, :direction, :interface ,:rest]
    values = input.match(/^(.* \d{2}:\d{2}:\d{2}).*? (\d+) (Deny|Allow) (ICMP):([^ ]*) ([^ ]*) ([^ ]*) (out|in) via ([^\s])*\s*(.*)/)
  end

  if values.nil?
    STDERR.puts "Error: #{input}" if DEBUG
    next
  else
    fields = Hash[*keys.zip(values.captures).flatten]
  end

  if reverse
    if fields[:sport] < 1024 && fields[:dport] > 1024
      fields[:sport], fields[:dport]  = fields[:dport], fields[:sport]
      fields[:sip],   fields[:dip]    = fields[:dip],   fields[:sip]
      STDERR.puts "Reversed #{fields[:sport]} #{fields[:dport]}" if DEBUG
    end
  end

  if output == "full"
    puts fields.values_at(:timestamp, :rulenumber, :action, :direction, :interface, :sip, :sport, :dip, :dport, :proto, :app, :direction, :rest).join(",")
  else
    tokens = output.split(" ").map{|e| e.to_sym}
    tokens.each { |token| STDERR.puts "Error: #{token} is not a known field" unless fields.has_key?(token) }
    puts fields.values_at(*tokens).compact.join(",")
  end

end
