
get '/list.json' do
  Printer.list.to_json
end

post '/file' do
  if !params[:file] or !params[:printer]
    status 400
    @mes = 'bad request'
  else
    data = params[:file][:tempfile].read
    fname = "#{filedir}/#{Digest::MD5.hexdigest data}#{File.extname params[:file][:filename]}"
    File.open(fname, 'wb') do |f|
      f.write data
    end
    unless File::exists? fname
      status 500
      @mes = 'file upload error'
    else
      begin
        Printer.new(params[:printer]).print(fname)
        @mes = 'printing!!'
      rescue => e
        STDERR.puts e
        @mes = e.to_s
      end
    end
  end
end
