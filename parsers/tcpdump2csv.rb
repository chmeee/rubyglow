#!/usr/bin/env ruby

# Usage:	tcpdump -vttttnnelr /tmp/log.tcpdump | ./tcpdump2csv.pl ["field list"]

output             = ARGV[0] || "full"
DEBUG              = false
client_server_conn = Hash.new

STDIN.each do |input|
  input.chomp!

  values = input.match(/(\d+-\d+-\d+ \d+:\d+:\d+\.\d+) (\S+) > (\S+), ethertype (\S+) \(\S+\), length:? (\d+):? (?:\S+ )?\((?:tos +(\S+), )?(?:ttl +(\d+), )?(?:id +(\d+), )?(?:offset +(\d+), )?(?:flags \[(\S+)\], )?(?:proto: (\S+).*?, )?(?:length: (\d+))?.*?\) (\S+?)(?:\.(\d+))? > (\S+?)(?:\.(\d+))?: +(?:(\S+),? (.*?)|\d+[\+\*\-]* \d+\/\d+\/\d+ (\S+) (\S+) (\S+) .*?|\d+[\+\*\-]* (\S+) (\S+) .*?)?/)

  if values.nil?
    STDERR.puts "Error: #{input}" if DEBUG
    next
  else
    keys = [ :timestamp, :sourcemac, :destmac, :etherproto, :len, :tos, :ttl, :id, :offset, :ipflags, :proto, :len, :sip, :sport, :dip, :dport, :flags, :rest, :dnshostresponse, :dnslookup, :dnsipresponse, :dnstype, :dnslookup ]
    fields = Hash[*keys.zip(values.captures.map!{|e| e || "" }).flatten]
    next if fields[:etherproto] == "802.3,"
    next if fields[:etherproto] == "ARP"

    fields[:timestamp].gsub!(/(.*?)\.\d+$/, '\1')
    fields[:sourcemac].gsub!(/,$/, '')
    fields[:len].gsub!(/,$/, '')
  end

  fields[:flags] += "A" if input =~ / ack /
  conn_id         = fields.values_at(:sip, :dip, :sport, :dport).join
  reverse_conn_id = fields.values_at(:dip, :sip, :dport, :sport).join

  if fields[:flags] =~ /S.*A/
    client_server_conn[reverse_conn_id] = true
    fields[:sourcemac], fields[:destmac] = fields[:destmac], fields[:sourcemac] 
    fields[:sip],       fields[:dip]     = fields[:dip],     fields[:sip]
    fields[:sport],     fields[:dport]   = fields[:dport],   fields[:sport]
  elsif fields[:flags] =~ /S/
    client_server_conn[conn_id] = true
  elsif client_server_conn[reverse_conn_id]
    fields[:sourcemac], fields[:destmac] = fields[:destmac], fields[:sourcemac] 
    fields[:sip],       fields[:dip]     = fields[:dip],     fields[:sip]
    fields[:sport],     fields[:dport]   = fields[:dport],   fields[:sport]
  elsif !client_server_conn[reverse_conn_id] && !client_server_conn[conn_id] && fields[:proto] == "tcp"
    if fields[:sport] < 1024 && fields[:dport] > 1024
      fields[:sourcemac], fields[:destmac] = fields[:destmac], fields[:sourcemac] 
      fields[:sip],       fields[:dip]     = fields[:dip],     fields[:sip]
      fields[:sport],     fields[:dport]   = fields[:dport],   fields[:sport]
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
