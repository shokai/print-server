# -*- coding: utf-8 -*-
before '/*.json' do
  content_type 'application/json'
end

get '/' do
  @title = @@conf['title']
  @printers = Printer.list
  haml :index
end

