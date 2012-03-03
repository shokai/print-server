#!/usr/bin/env ruby
## capture webpage and make PDF
## brew install capybara capybara-webkit headless

require 'rubygems'
require 'capybara-webkit'
require 'headless'
require 'tmpdir'
require 'prawn'

class WebCapture
  class Error < StandardError
  end
  def self.capture(params)
    tmp_fname = "capture.png"
    Dir.mktmpdir('print-server') do |dir|
      png = "#{dir}/#{tmp_fname}"
      Headless.ly do
        driver = Capybara::Driver::Webkit.new 'web_capture'
        driver.visit params[:url]
        driver.render png
      end
      
      raise Error.new "capture failed" unless File.exists? png

      x,y = `identify '#{png}'`.split(/\s/).select{|i|
        i =~ /^\d+x\d+$/
      }.first.split('x').map{|i| i.to_i}
      
      w = x
      h = params[:landscape] ? (w/1.41).to_i : (w*1.41).to_i
      
      parts = 0.upto(y/h).map{|i|
        fname = "#{dir}/#{i}.jpg"
        puts cmd = "convert -quality 100 -crop #{w}x#{h}+0+#{h*i} '#{png}' '#{fname}'"
        system cmd
        fname
      }
      
      Prawn::Document.generate(params[:out]) do
        parts.each do |img|
          text params[:url]
          image img, :fit => [bounds.width, bounds.height-20]
        end
      end
    end
  end
end


if __FILE__ == $0
  ## WebCapture.capture(:url => 'http://shokai.org', :out => 'out.pdf')

  require 'ArgsParser'

  parser = ArgsParser.parser
  parser.bind(:help, :h, 'show help')
  parser.comment(:url, 'URL')
  parser.bind(:width, :w, 'page width', 1200)
  parser.comment(:landscape, 'landscape layout', false)
  parser.bind(:out, :o, 'output file', 'out.pdf')
  first, params = parser.parse(ARGV)
  
  if parser.has_option(:help) or !parser.has_params([:url])
    puts parser.help
    puts "e.g.  ruby #{$0} -url http://shokai.org/blog/ -out shokai-blog.pdf"
    exit 1
  end

  WebCapture.capture(params)
end
