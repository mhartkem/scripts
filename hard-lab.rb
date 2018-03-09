# to edit, use "nano /share/apache_log_analyzer.rb"

#ip_addresses = Hash.new(0)

error_regex = /404/

File.open("/var/log/apache2/access.log").each do |line|
  ip = ip_regex.match(line)
  puts ip
  url = url_regex.match(line)
  puts url
  if url == "secret.html" then secret = true
  puts url
  error_regex.match(line)
end

#puts ip_addresses
