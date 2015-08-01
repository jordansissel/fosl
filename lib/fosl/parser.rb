require "fosl/namespace"
require "fosl/process"

class FOSL::Parser
  # Fields are separated by newlines or null
  # Fields start with a character followed by the data

  # These are the fields according to the lsof manpage.
  # If you want to implement one, you should write a 'parse_<field letter>'
  # method. It should return a hash of key => value you want to save.
  #
  # # The following copied mostly verbatim from the lsof manpage.
  #  - a    file access mode
  #  - c    process command name (all characters from proc or user structure)
  #  - C    file structure share count
  #  - d    file's device character code
  #  - D    file's major/minor device number (0x<hexadecimal>)
  #  - f    file descriptor
  #  - F    file structure address (0x<hexadecimal>)
  #  - G    file flaGs (0x<hexadecimal>; names if +fg follows)
  #  - i    file's inode number
  #  - k    link count
  #  - l    file's lock status
  #  - L    process login name
  #  - m    marker between repeated output
  #  - n    file name, comment, Internet address
  #  - N    node identifier (ox<hexadecimal>
  #  - o    file's offset (decimal)
  #  - p    process ID (always selected)
  #  - g    process group ID
  #  - P    protocol name
  #  - r    raw device number (0x<hexadecimal>)
  #  - R    parent process ID
  #  - s    file's size (decimal)
  #  - S    file's stream identification
  #  - t    file's type
  #  - T    TCP/TPI information, identified by prefixes (the
  #  - u    process user ID
  #  - z    Solaris 10 and higher zone name
  #  - Z    SELinux security context (inhibited when SELinux is disabled)

  # T is various network/tcp/socket information.
  def parse_T(data)
    prefix, value = data.split("=")
    case prefix
      when "ST" ; prefix = :state
      when "QR" ; prefix = :read_queue
      when "QS" ; prefix = :send_queue

      # (sissel) I don't know the  values of these fields. Feel free
      # to implement them and send me patches.
      #when "SO" ; prefix = :socket_options
      #when "SS" ; prefix = :socket_State
      #when "TF" ; prefix = :tcp_flags
      #when "WR" ; prefix = :read_window
      #when "WW" ; prefix = :write_window
    end
    return { prefix => value }
  end # def parse_T

  # The file's type
  def parse_t(data)
    return { :type => data }
  end

  # The protocol name
  def parse_P(data)
    return { :protocol => data }
  end

  # the pid
  def parse_p(data)
    new_pid(data.to_i)
    return :new_pid
  end

  # the file name or identifier
  def parse_n(data)
    return { :name => data }
  end

  # file descriptor (or 'cwd' etc...)
  def parse_f(data)
    new_file

    # Convert to int it looks like a number.
    if data.to_i != 0 or data == "0"
      data = data.to_i
    end

    return { :fd => data }
  end

  # The command name
  def parse_c(data)
    @current_process.command = data
    return nil
  end

  # The login name
  def parse_L(data)
    @current_process.login = data
    return nil
  end

  # state helper, creates a new process
  def new_pid(pid)
    new_file # push the last file (if any) onto the last process
    @current_process = FOSL::Process.new(pid)
  end

  # state helper, creates a new file hash
  def new_file
    if !@current_file.nil? && !@current_file.empty?
      @current_process.files << @current_file
    end

    @current_file = {}
  end

  # Parse output from an lsof(1) run. You must run
  # This output must be from lsof run with this flag '-F Pcfnt0'
  def parse(data)
    if data[0..0] != "p"
      raise "Expected first character to be 'p'. Unexpected data input - #{data[0..30]}..."
    end

    result = Hash.new { |h,k| h[k] = FOSL::Process.new(k) }

    data.split(/[\n\0]/).each do |field|
      next if field.empty?
      type = field[0 .. 0]
      value = field[1 .. -1]

      method = "parse_#{type}".to_sym
      if self.respond_to?(method)
        r = self.send(method, value)
        #p field => r
        if r.is_a?(Hash)
          @current_file.merge!(r)
        elsif r == :new_pid
          result[@current_process.pid] = @current_process
        end
      else
        $stderr.puts "Unsupported field type '#{type}': #{field.inspect}"
      end
    end

    # push last file
    new_file

    return result
  end # def parse

  # Helper for running lsof.
  # Returns the same thing as 'parse'
  #
  # Example:
  #   lsof("-i :443")
  def lsof(args="", command="lsof")
    cmd = "#{command} -F PcfntT0 #{args}"
    #puts cmd
    output = `#{cmd}`
    # Should we raise an exception, or just return empty results, on failure?
    if $?.exitstatus != 0
      raise "lsof exited with status #{$?.exitstatus}"
    end
    return self.parse(output)
  end
end # class FOSL::Parser
