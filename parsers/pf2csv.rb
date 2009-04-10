#!/usr/bin/env ruby

# Usage:	cat pflog | ./pf2csv.pl ["field list"]

output  = ARGV[0] || "full"
DEBUG   = true
reverse = true

STDIN.each do |input|
  input.chomp!
  keys = [:timestamp,:rulenumber,:action,:direction,:interface,:sip,:sport,:dip,:dport,:rest]
  values = input.match(/(.*) rule ([-\d]+\/\d+)\(.*?\): (pass|block) (in|out) on (\w+): (\d+\.\d+\.\d+\.\d+)\.?(\d*) [<>] (\d+\.\d+\.\d+\.\d+)\.?(\d*): (.*)/)

  if values.nil?
    STDERR.puts "Error: #{input}" if DEBUG
    next
  else
    fields = Hash[*keys.zip(values.captures).flatten]
  end

  case fields[:rest]
  when /icmp: echo/
    fields[:proto] = "icmp"
    if fields[:rest] =~ /icmp: (echo \S+)(.*)/
      fields[:rest]  = $2
      fields[:dport] = $1
    end
  when /^([SFP\.RU][^ ]*) ([^ ]*) (?:(ack))?(.*)/
    fields[:proto] = "tcp"
    fields[:flags] = $1
    fields[:seq]   = $2
    fields[:ack]   = $3
    fields[:rest]  = $4
  when /\d+ ServFail/
    fields[:proto] = "udp"
    fields[:app]   = "dns"
  when /udp (\d+)/
    fields[:proto] = "udp"
    fields[:len]   = $1
  end

  if reverse
    if fields[:flags] == "S" && fields[:sport] != 20 && !fields[:ack]
    elsif fields[:flags] == "S" && fields[:ack]
      fields[:sport], fields[:dport]  = fields[:dport], fields[:sport]
      fields[:sip],   fields[:dip]    = fields[:dip],   fields[:sip]
      STDERR.puts "Reversed #{fields[:sport]} #{fields[:dport]}" if DEBUG
    elsif fields[:sport].to_i < 1024 && fields[:dport].to_i > 1024
      fields[:sport], fields[:dport]  = fields[:dport], fields[:sport]
      fields[:sip],   fields[:dip]    = fields[:dip],   fields[:sip]
      STDERR.puts "Reversed #{fields[:sport]} #{fields[:dport]}" if DEBUG
    end
  end

  if output == "full"
    puts fields.values_at(:timestamp, :rulenumber, :action, :direction, :interface, :sip, :sport, :dip, :dport, :flags, :proto, :app, :rest).join(",")
  else
    tokens = output.split(" ").map{|e| e.to_sym}
    tokens.each { |token| STDERR.puts "Error: #{token} is not a known field" unless fields.has_key?(token) }
    puts fields.values_at(*tokens).compact.join(",")
  end

end
