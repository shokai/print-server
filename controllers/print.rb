
get '/list.json' do
  Printer.list.to_json
end

post '/file' do
  if !params[:file] or !params[:printer]
    status 400
    @mes = 'bad request'
    haml :message
  else
    data = params[:file][:tempfile].read
    fname = "#{filedir}/#{Digest::MD5.hexdigest data}#{File.extname params[:file][:filename]}"
    File.open(fname, 'wb') do |f|
      f.write data
    end
    unless File::exists? fname
      status 500
      @mes = 'file upload error'
      haml :message
    else
      begin
        pr = Printer.new(params[:printer])
        pr.print(fname) unless @@conf['no_print']
        @mes = 'printing!!'
        haml :message
      rescue => e
        STDERR.puts e
        @mes = e.to_s
        haml :message
      end
    end
  end
end
