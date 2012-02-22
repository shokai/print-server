
def app_root
  "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}"
end

def filedir
  File.dirname(__FILE__)+'/../files'
end
