
get '/list.json' do
  Printer.list.to_json
end

post '/file' do
  if !params[:file] or !params[:file][:tempfile]
    status 400
    @mes = 'bad request'
    haml :message
  else
    f = Tempfile.new('print-server')
    begin
      f.write params[:file][:tempfile].read
      pr = Printer.new(params[:printer] || @@conf['default_printer'] || Printer.default)
      f.close
      pr.print(f.path) unless @@conf['no_print']
      @mes = 'printing!!'
      haml :message
    rescue => e
      STDERR.puts e
      status 500
      @mes = e.to_s
      haml :message
    ensure
      f.delete
    end
  end
end

post '/url' do
  if !params[:url]
    status 400
    @mes = 'bad request'
    haml :message
  else
    begin
      pr = Printer.new(params[:printer] || @@conf['default_printer'] || Printer.default)
      PrintWebpage.print(pr, params[:url])
      @mes = "#{params[:url]} printing!!"
      haml :message
    rescue => e
      STDERR.puts e
      status 500
      @mes = e.to_s
      haml :message
    end
  end
end
