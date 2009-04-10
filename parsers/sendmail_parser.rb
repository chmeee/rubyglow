#!/usr/bin/env ruby

# File: 	sendmail_parser.pl logfile [outputformat]

if ARGV.length < 1
  puts "Wrong number of arguments!"
  puts "Usage: ./sendmail_parser.pl logfile [fields]"
  exit
end

file   = ARGV[0]
output = ARGV[1] || "full"

from_regex = /.*? (\\S+?): from=<?(.*?)>?, size=(.*?), class=(.*?),(?: pri=(.*?),)? nrcpts=(.*?),(?: msgid=<?(.*?)>?,)? (?:bodytype=(.*?), )?(?:proto=(.*?), )?(?:daemon=(.*?), )?relay=(.*?)(?: \\[(.*?)\\])?.*?/

to_regex = /.*? (\\S+?): to=<?(.*?)>?,(?: ctladdr=<?(.*?)>? [^,]*,)? delay=(.*?),(?: xdelay=(.*?),)? mailer=(.*?),(?: pri=(.*?),)?(?: relay=(.*?) \\[(.*?)\\],)?(?: dsn=(.*?),)? stat=([^ ]*)(?: .*)?/

File.open(file) do |f|
  messages = Hash.new
  fields   = Hash.new

  f.each do |line|
    line.chomp!
    from_match = line.match(from_regex)
    if not from_match.nil?
      messages[$1] = from_match.captures
    elsif line.match(to_regex)
      if messages[$1]
        f_array = messages[$1]

        fields[:from]     = f_array[1]  || ""
        fields[:to]       = $2          || ""
        fields[:size]     = f_array[2]  || ""
        fields[:class]    = f_array[3]  || ""
        fields[:pri]      = f_array[4]  || ""
        fields[:nrcpts]   = f_array[5]  || ""
        fields[:msgid]    = f_array[6]  || ""
        fields[:bodytype] = f_array[7]  || ""
        fields[:proto]    = f_array[8]  || ""
        fields[:daemon]   = f_array[9]  || ""
        fields[:relay]    = f_array[10] || ""
        fields[:ctladdr]  = $3          || ""
        fields[:delay]    = $4          || ""
        fields[:xdelay]   = $5          || ""
        fields[:mailer]   = $6          || ""
        fields[:pri2]     = $7          || ""
        fields[:relay2]   = $8          || ""
        fields[:relay2_1] = $9          || ""
        fields[:dsn]      = $10         || ""
        fields[:stat]     = $11         || ""
        if output == "full"
          printf ("| From: %30s ",fields[:from])
          printf ("| To: %28s ",fields[:to])
          printf ("| relay: %5s",fields[:relay])
          puts
          puts
          printf ("| msgid: %35s ",fields[:msgid])
          printf ("| externalID: %10s ",$1)
          puts
          printf ("| size: %5s ",fields[:size])
          printf ("| class: %5s ", fields[:class])
          printf ("| pri: %5s ", fields[:pri])
          printf ("| nrcpts: %5s ",fields[:nrcpts])
          printf ("| bodytype: %5s ",fields[:bodytype])
          printf ("| proto: %5s ",fields[:proto])
          printf ("| daemon: %5s ",fields[:daemon])
          puts
          printf ("| ctladdr: %15s ",fields[:ctladdr])
          printf ("| delay: %15s ",fields[:delay])
          printf ("| xdelay: %15s ",fields[:xdelay])
          printf ("| mailer: %15s ",fields[:mailer])
          printf ("| pri2: %15s ",fields[:pri2])
          puts
          printf ("| relay2: %15s %15s",fields[:relay2], fields[:relay2_1])
          printf ("| dsn: %15s ",fields[:dsn])
          printf ("| stat: %15s ",fields[:stat])
          puts
        end
      else
        tokens = output.split(" ").map{|e| e.to_sym}
        tokens.each { |token| STDERR.puts "Error: #{token} is not a known field" unless fields.has_key?(token) }
        puts fields.values_at(*tokens).compact.join(",")
      end
    end
  end
end
