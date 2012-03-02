
class Printer
  class Error < StandardError
  end

  attr_reader :name

  def self.default
    `lpstat -s`.split(/[\r\n]/)[0].scan(/[a-zA-Z0-9_\-]+$/).first.first
  end

  def self.list
    ps = `lpstat -s`.split(/[\r\n]/)
    ps.shift
    ps.map{|i| i.scan(/^[^\s]+/).first}.uniq
  end

  def initialize(name=Printer.default)
    unless Printer.list.include? name
      raise Error.new("Printer \"#{name}\" is not exists")
    end
    @name = name
  end

  def print(file_name)
    raise Error.new("File not exists (#{file_name})") unless File.exists? file_name
    unless system "lpr -P #{@name} #{file_name}"
      raise Error.new('Print Error')
    end
  end
end

if $0 == __FILE__
  if ARGV.size < 2
    puts "== printer list =="
    puts Printer.list
    puts "== defualt printer =="
    puts Printer.default
    puts "== print file =="
    puts "ruby printer.rb PRINTER_NAME FILE_NAME"
  else
    begin
      pr = Printer.new(ARGV.shift)
      puts "printer : #{pr.name}"
      pr.print(ARGV.shift)
      puts "printing!!"
    rescue => e
      STDERR.puts e
    end
  end
end
