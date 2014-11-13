Pod::Spec.new do |s|
  s.name          = "DBImageView"
  s.version       = "1.3"
  s.summary       = "A simple object to load images asynchronously"
  s.license       = "MIT"
  s.author        = { "Daniele Bogo" => "me@bogodaniele.com" }
  s.platform      = :ios, "6.0"
  s.homepage      = 'https://github.com/danielebogo/DBImageView'
  s.source        = { :git => "https://github.com/danielebogo/DBImageView.git", :tag => "1.3" }
  s.source_files  = "DBImageView/*.{h,m}"
  s.requires_arc = true
end
