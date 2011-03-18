require "lsof/namespace"

class LSOF::Process
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
end # class LSOF::Process
