#!/usr/bin/env ruby

require 'trollop'
require 'fastercsv'

opts = Trollop::options do
  opt :column, "indicate the column that should be anonymized [starting with one!]", :short => "-c", :type => :integer, :default => 0
  opt :prefix, "prefix to use for anonymization", :short => "-p", :type => String, :default => ""
end

column = opts[:column] - 1

value = Hash.new
current_val = 1
obj = nil

output_csv = FasterCSV.generate do |out_line|

  FasterCSV.new(STDIN).each do |line|
    if line[column] =~ /^\d{1,3}(?:\.\d{1,3}){3}$/
      if obj.nil?
        require 'ip_anonymous'
        key = [2,3,30,31,43,5,6,7,8,9,10,11,12,13,14,15, 16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
        obj = IP::Anonymous.new(key)
      end
      line[column] = obj.anonymize(line[column])
    else
      number = value[line[column]] || current_val
      if number == current_val
        value[line[column]] = current_val
        current_val += 1
      end
      line[column] = opts[:prefix] + number.to_s
    end

    out_line << line
  end

end

puts output_csv
