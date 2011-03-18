
$: << File.join(File.dirname(__FILE__), "..", "lib")

require "rubygems"
require "lsof/parser"

if ARGV.size == 0
  $stderr.puts "Usage: #{$0} pid [pid ...]"
  exit 1
end


lsof = LSOF::Parser.new
pidflags = ARGV.collect { |a| "-p #{a}" }.join(" ")
results = lsof.lsof("-nP #{pidflags}")

results.each do |pid, process|
  process.files.each do |file|
    p pid => file
  end
end
