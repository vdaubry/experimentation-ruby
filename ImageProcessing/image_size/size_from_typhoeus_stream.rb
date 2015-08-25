require 'typhoeus'

url = "http://imgsv.imaging.nikon.com/lineup/dslr/d600/img/sample01/img_04_l.jpg"
request = Typhoeus::Request.new(url)
request.on_body do |chunk|
  :abort
end
request.run