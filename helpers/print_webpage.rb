require 'net/http'
require 'uri'
require 'tempfile'
require 'tmpdir'
require 'open-uri'
require 'digest/md5'
require File.dirname(__FILE__)+'/web_capture'

class PrintWebpage
  class Error < StandardError
  end

  def self.content_type(url)
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port){|http|
      res = http.head(uri.path.size < 1 ? '/' : uri.path)
      return res.header.content_type
    }
  end

  def self.html?(url)
    content_type(url) =~ /html/ ? true : false
  end
  
  def self.print(printer, url)
    raise Error.new("#{printer.class} is not Instance of Printer class") unless printer.class == Printer
    raise Error.new("#{url} is not HTTP URL") unless url =~ /^https?:\/\/.+$/
    unless PrintWebpage.html? url
      f = open(url)
      f.close
      printer.print(f.path)
    else
      Dir.mktmpdir do |dir|
        pdf = "#{dir}/#{Digest::MD5.hexdigest url}.pdf"
        WebCapture.capture({:url => url, :out => pdf})
        printer.print(pdf)
      end
    end
  end
end


if __FILE__ == $0
  require File.dirname(__FILE__)+'/printer'

  if ARGV.empty?
    puts "e.g.  ruby #{$0} Printer_Name http://shokai.org"
    puts "==printers=="
    puts Printer.list
    exit 1
  end

  pr = Printer.new(ARGV.shift)

  url = ARGV.empty? ? 'http://shokai.org' : ARGV.shift
  puts "print #{url}"
  PrintWebpage.print(pr, url)
end
