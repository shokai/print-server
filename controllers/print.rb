
post '/file' do
  if !params[:file]
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
      @mes = 'upload error'
    else
      @mes = 'success'
    end
  end
end
