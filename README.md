# ruby lsof api


## Example usage:

    require "rubygems" 
    require "ap" 
    require "lsof/parser" 

    a = LSOF::Parser.new 
    data = a.lsof("-nP")

    # Show any process with listening sockets:
    data.map do |pid, process|
      next if process.listeners.empty?
      # 'process' here is an instance of LSOF::Process

      ap :pid => pid,
         :command => process.command,
         :listeners => process.listeners
    end
  
Sample output:

    {
      :command   => "smbd",
      :pid       => 1007,
      :listeners => [
        [0] {
          :protocol   => "TCP",
          :state      => "LISTEN",
          :fd         => 22,
          :read_queue => "0",
          :name       => "*:445",
          :send_queue => "0"
        },
        [1] {
          :protocol   => "TCP",
          :state      => "LISTEN",
          :fd         => 23,
          :read_queue => "0",
          :name       => "*:139",
          :send_queue => "0"
        }
      ]
    }
    {
      :command   => "nginx",
      :pid       => 1846,
      :listeners => [
        [0] {
          :protocol   => "TCP",
          :state      => "LISTEN",
          :fd         => 7,
          :read_queue => "0",
          :name       => "*:80",
          :send_queue => "0"
        }
      ]
    }
