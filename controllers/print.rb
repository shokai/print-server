
get '/list.json' do
  Printer.list.to_json
end

post '/file' do
  if !params[:file] or !params[:file][:tempfile] or !params[:printer]
    status 400
    @mes = 'bad request'
    haml :message
  else
    f = Tempfile.new('print-server')
    begin
      f.write params[:file][:tempfile].read
      pr = Printer.new(params[:printer])
      pr.print(fname) unless @@conf['no_print']
      @mes = 'printing!!'
      haml :message
    rescue => e
      STDERR.puts e
      status 500
      @mes = e.to_s
      haml :message
    ensure
      f.close
      f.delete
    end
  end
end
