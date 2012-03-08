#!/usr/bin/env ruby
require 'rubygems'
require 'goldfish'
require 'ArgsParser'
require 'net/http'
require 'uri'

parser =ArgsParser.parser
parser.comment(:tag, 'NFC tag ID')
parser.bind(:help, :h, 'show help')
parser.bind(:printer_url, :printer, 'URL of Printer API', 'http://localhost:8080')

first, params = parser.parse ARGV
p params

if parser.has_option(:help) or !parser.has_params([:tag, :printer_url])
  puts "e.g.  ruby #{$0} -tag a1bc2345def6 -printer http://localhost:8080"
  exit 1
end

unless params[:tag] =~ /^[a-zA-Z0-9]+$/
  STDERR.puts "invalid NTC-Tag ID (#{params[:tag]})"
  exit 1
end

unless params[:printer_url] =~ /^https?:\/\/.+/
  STDERR.puts "invalid Printer URL (#{params[:printer_url]})"
  exit 1
end

params[:printer_url].gsub!(/\/+$/,'')
api = URI.parse "#{params[:printer_url]}/url"

params[:tag] = params[:tag].downcase
poi = GoldFish::Poi.new

loop do
  data = poi.get(params[:tag])
  puts data
  if data =~ /^https?:\/\/.+/
    begin
      puts cmd = "say ウェブページを印刷します"
      system cmd
      Net::HTTP.start(api.host, api.port){|http|
        res = http.post(api.path, "url=#{URI.encode data}")
        if res.code.to_i == 200
          puts cmd = "say 印刷しています"
          system cmd
          puts "printing"
        else
          puts cmd = "say 印刷に失敗しました"
          system cmd
          STDERR.puts "print error!"
        end
      }
    rescue => e
      STDERR.puts e
    end
  end
end
