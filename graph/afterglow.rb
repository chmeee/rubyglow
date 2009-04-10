#!/usr/bin/env ruby

def property_file(prop_file_name)
  File.open(prop_file_name) do |prop_file|
    prop_file.each_with_index do |line, line_no|
      line.chomp!
      next if line =~ /^\s*#/ or line =~ /^\s*$/
      line.gsub!(/#.*$/,'')

    end
  end
end
