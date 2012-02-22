# -*- coding: utf-8 -*-
before '/*.json' do
  content_type 'application/json'
end

before '/*' do
  @title = @@conf['title']
end

get '/' do
  @printers = Printer.list
  haml :index
end

