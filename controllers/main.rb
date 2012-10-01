before '/*.json' do
  content_type 'application/json'
end

before '/*' do
  @title = Conf['title']
end

get '/' do
  @printers = Printer.list
  haml :index
end

