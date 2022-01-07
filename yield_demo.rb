def get_website_contents
  puts "<body>"
  yield
  puts "</body>"
end


get_website_contents { puts "Something" }

get_website_contents do
  puts "something!!!"
end

