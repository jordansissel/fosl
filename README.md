# fosl, a ruby lsof api

Status:

The API works now, but is less a true API and more a light hash-ish wrapping on
lsof output.

## Example: 'lsof.rb'

Code: <https://github.com/jordansissel/ruby-lsof/blob/master/examples/lsof.rb>

This example runs 'lsof' like you would normally, but captures the output into
ruby.

    % sudo ruby lsof.rb -i :80 -s TCP:LISTEN
    {1846=>{:type=>"IPv4", :send_queue=>"0", :protocol=>"TCP", :state=>"LISTEN", :name=>"*:www", :fd=>7, :read_queue=>"0"}}
    {1847=>{:type=>"IPv4", :send_queue=>"0", :protocol=>"TCP", :state=>"LISTEN", :name=>"*:www", :fd=>7, :read_queue=>"0"}}

    % ps -fp 1846 -p 1847
    UID        PID  PPID  C STIME TTY          TIME CMD
    root      1846     1  0 Mar08 ?        00:00:00 nginx: master process /usr/sbin/nginx
    www-data  1847  1846  0 Mar08 ?        00:00:01 nginx: worker process

## Example: What files do I have open?

Code: <https://github.com/jordansissel/ruby-lsof/blob/master/examples/lsofpid.rb>

Output:

    % sudo ruby lsofpid.rb 1
    {1=>{:fd=>"cwd", :name=>"/"}}
    {1=>{:fd=>"rtd", :name=>"/"}}
    {1=>{:fd=>"txt", :name=>"/sbin/init"}}
    {1=>{:fd=>"mem", :name=>"/lib/libnss_files-2.11.1.so"}}
    ... output omitted ...
    {1=>{:fd=>"mem", :name=>"/lib/ld-2.11.1.so"}}
    {1=>{:fd=>0, :name=>"/dev/null"}}
    {1=>{:fd=>1, :name=>"/dev/null"}}
    {1=>{:fd=>2, :name=>"/dev/null"}}
    {1=>{:fd=>3, :name=>"pipe"}}
    {1=>{:fd=>4, :name=>"pipe"}}
    {1=>{:fd=>5, :name=>"inotify"}}
    {1=>{:fd=>6, :name=>"inotify"}}
    {1=>{:fd=>7, :name=>"socket"}}
    {1=>{:fd=>8, :name=>"socket"}}
    {1=>{:fd=>9, :name=>"socket"}}
    {1=>{:fd=>10, :name=>"socket"}}


## Example usage (Show all listeners):

    require "rubygems" 
    require "ap" 
    require "lsof/parser" 

    a = LSOF::Parser.new 
    data = a.lsof("-nP") # runs "lsof -nP", roughly.

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

