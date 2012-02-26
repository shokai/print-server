#!/usr/bin/env ruby
## capture webpage and make PDF
## brew install webkit2png imagemagick pdfjam

require 'rubygems'
require 'FileUtils'

class WebCapture
  def self.capture(params)
    tmp_fname = "#{Time.now.to_i}_#{Time.now.usec}"
    tmp_dname = File.dirname(params[:out])+'/'+tmp_fname
    
    FileUtils.mkdir_p(tmp_dname) unless File.exists? tmp_dname
    puts cmd = "webkit2png --dir '#{tmp_dname}' -o #{tmp_fname} -F -W #{params[:width].to_i} '#{params[:url]}'"
    system cmd
    
    unless png = Dir.glob("#{tmp_dname}/#{tmp_fname}*-full.png")[0]
      STDERR.puts "capture failed"
      exit 1
    end
    
    x,y = `identify '#{png}'`.split(/\s/).select{|i|
      i =~ /^\d+x\d+$/
    }.first.split('x').map{|i| i.to_i}
    
    w = x
    h = params[:landscape] ? (w/1.41).to_i : (w*1.41).to_i
    
    parts = 0.upto(y/h).map{|i|
      fname = "#{tmp_dname}/#{i}.png"
      puts cmd = "convert -crop #{w}x#{h}+0+#{h*i} '#{png}' '#{fname}'"
      system cmd
      fname
    }
    
    scape = params[:landscape] ? 'landscape' : 'no-landscape'
    puts cmd = "pdfjam --#{scape} --outfile '#{params[:out]}' --pdftitle '#{params[:url]}' #{parts.join(' ')}"
    system cmd
    
    Dir.glob("#{tmp_dname}/*").each{|f|
      File.delete f
    }
    Dir.rmdir tmp_dname
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
