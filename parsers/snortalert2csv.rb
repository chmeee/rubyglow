#!/usr/bin/env ruby

# Usage:	cat snortalert | ./snortalert2csv.pl ["field list"]

output  = ARGV[0] || "full"
DEBUG   = true
fields = Hash.new

STDIN.each do |input|
  input.chomp!

  case input
  when /\s*\[\*\*\] \[(\S+)\] (.*) \[\*\*\]/
    fields[:sid]  = $1
    fields[:name] = $2
  when /([^ ]*) (\S+?)(?::(\d+))? -> ([^:]+)(?::(\d+))?/
    fields[:timestamp] = $1
    fields[:sip]       = $2
    fields[:sport]     = $3
    fields[:dip]       = $4
    fields[:dport]     = $5
  when /\[Classification: ([^\]]*) \[Priority: (\S+)\]/ 
    fields[:classification] = $1
    fields[:priority]       = $2
  when /(\S+) TTL:(\d+) TOS:(\S+) ID:(\d+) IpLen:(\d+) DgmLen:(\d+)/
    fields[:proto]  = $1
    fields[:ttl]    = $2
    fields[:tos]    = $3
    fields[:sid]    = $4
    fields[:iplen]  = $5
    fields[:dgmlen] = $6
  when /(\S+) Seq: (\S+)  Ack: (\S+)  Win: (\S+)  TcpLen: (\d+)/
    fields[:flags]  = $1
    fields[:seq]    = $2
    fields[:ack]    = $3
    fields[:win]    = $4
    fields[:tcplen] = $5
  end

  if input =~ /^\s*\[\*\*\]/
    if output == "full"
      puts fields.values_at(:timestamp, :sid, :name, :sip, :dip, :sport, :dport, :proto, :classification, :priority, :ttl, :tos, :id, :iplen, :dgmlen, :flags, :seq, :ack, :win, :tcplen).join(",")
    else
      tokens = output.split(" ").map{|e| e.to_sym}
      tokens.each { |token| STDERR.puts "Error: #{token} is not a known field" unless fields.has_key?(token) }
      puts fields.values_at(*tokens).compact.join(",")
    end
    fields = Hash.new
  end
end
