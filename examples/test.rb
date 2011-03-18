require "rubygems" 
require "ap" 
require "fosl/parser" 

a = FOSL::Parser.new 
data = a.lsof("-nP")

# Show any process with listening sockets:
data.map do |pid, process|
  next if process.listeners.empty?

  ap :pid => pid,
     :command => process.command,
     :listeners => process.listeners
end

