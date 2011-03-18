require "lsof/namespace"
require "lsof/process"

class LSOF::Parser
  # Fields are separated by newlines or null
  # Fields start with a character followed by the data
  
  FIELDS = {
    #a    file access mode
    #c    process command name (all characters from proc or user structure)
    #C    file structure share count
    #d    file's device character code
    #D    file's major/minor device number (0x<hexadecimal>)
    #f    file descriptor
    #F    file structure address (0x<hexadecimal>)
    #G    file flaGs (0x<hexadecimal>; names if +fg follows)
    #i    file's inode number
    #k    link count
    #l    file's lock status
    #L    process login name
    #m    marker between repeated output
    #n    file name, comment, Internet address
    #N    node identifier (ox<hexadecimal>
    #o    file's offset (decimal)
    #p    process ID (always selected)
    #g    process group ID
    #P    protocol name
    #r    raw device number (0x<hexadecimal>)
    #R    parent process ID
    #s    file's size (decimal)
    #S    file's stream identification
    #t    file's type
    #T    TCP/TPI information, identified by prefixes (the
    #u    process user ID
    #z    Solaris 10 and higher zone name
    #Z    SELinux security context (inhibited when SELinux is disabled)
  }

  #T    TCP/TPI information, identified by prefixes (the
  def parse_T(data)
    prefix, value = data.split("=")
    case prefix
      when "ST" ; prefix = :state
      when "QR" ; prefix = :read_queue
      when "QS" ; prefix = :send_queue
    end
    return { prefix => value }
  end # def parse_T

  def parse_t(data)
    return { :type => data }
  end

  def parse_P(data)
    return { :protocol => data }
  end

  def parse_p(data) 
    new_pid(data.to_i)
    return :new_pid
  end

  def parse_n(data) # file name/identifier
    return { :name => data }
  end

  def parse_f(data) # file descriptor (or 'cwd' etc...)
    new_file

    # Convert to int it looks like a number.
    if data.to_i != 0 or data == "0"
      data = data.to_i
    end

    return { :fd => data }
  end

  def parse_c(data) # command name
    @current_process.command = data
    return nil
  end

  def new_pid(pid)
    new_file # push the last file (if any) onto the last process
    @current_process = LSOF::Process.new(pid)
  end

  def new_file
    if !@current_file.nil? && !@current_file.empty?
      @current_process.files << @current_file
    end

    @current_file = {}
  end

  def parse(data, &block)
    result = Hash.new { |h,k| h[k] = LSOF::Process.new(k) }

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

  def lsof(args="")
    return self.parse(`lsof -F PcfnT0 #{args}`)
  end
end # class LSOF::Parser
