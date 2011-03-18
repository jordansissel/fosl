require "fosl/namespace"

class FOSL::Process
  attr_reader :files
  attr_reader :pid
  attr_accessor :command

  def initialize(pid)
    @command = nil
    @pid = pid
    @files = []
  end

  # helpers
  def listeners 
    @files.find_all { |f| f[:state] == "LISTEN" }
  end
end # class FOSL::Process
