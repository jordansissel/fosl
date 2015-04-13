require "fosl/namespace"

class FOSL::Process
  attr_reader :files
  attr_reader :pid
  attr_accessor :command
  attr_accessor :login

  def initialize(pid)
    @command = nil
    @login = nil
    @pid = pid
    @files = []
  end

  # helpers
  def listeners
    @files.find_all { |f| f[:state] == "LISTEN" }
  end
end # class FOSL::Process
