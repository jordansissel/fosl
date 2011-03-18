require "lsof/namespace"

class LSOF::Process
  attr_reader :files
  attr_reader :pid

  def initialize(pid)
    @pid = pid
    @files = []
  end

  # helpers
  def listeners 
    @files.reject { |f| f[:state] != "LISTEN" }
  end
end # class LSOF::Process
