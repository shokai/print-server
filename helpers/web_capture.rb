#!/usr/bin/env ruby
## capture webpage and make PDF
## brew install qt imagemagick
## gem install capybara capybara-webkit headless prawn mini_magick

require 'rubygems'
require 'capybara-webkit'
require 'headless'
require 'tmpdir'
require 'prawn'
require 'mini_magick'

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
      
      img = MiniMagick::Image.open png
      w = img[:width]
      h = params[:landscape] ? (w/1.41).to_i : (w*1.41).to_i
      
      parts = 0.upto(img[:height]/h).map{|i|
        fname = "#{dir}/#{i}.jpg"
        img = MiniMagick::Image.open png
        img.crop("#{w}x#{h}+0+#{i*h}")
        img.write fname
        fname
      }
      
      Prawn::Document.generate(params[:out],
                               :page_layout => params[:landscape] ? :landscape : :portrait) do
        for i in 0...(parts.size) do
          img = parts[i]
          start_new_page if i > 0
          text "#{params[:url]} [#{i+1}/#{parts.size}]"
          image img, :fit => [bounds.width, bounds.height-20]
        end
      end

      raise Error.new 'could not make PDF!!' unless File.exists? params[:out]
      params[:out]
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

  out = WebCapture.capture(params)
  puts " => #{out}"
end
