email = "foo"
password = "bar"
template = ERB.new File.read("scripts/.netrc.erb")
File.open(".netrc", "w") do |f|
    f.write(template.result(binding))
end