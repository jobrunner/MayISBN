Pod::Spec.new do |s|
  s.name             = 'MayISBN'
  s.version          = '0.1.0'
  s.summary          = 'Library for validation and formatting ISBNs offline'
 
  s.description      = <<-DESC
Validates and formatts ISBN (International Standard Book Number). It supports either ISBN-10 and ISBN-13.    
                       DESC
 
  s.homepage         = 'https://github.com/jobrunner/MayISBN'
  s.license          = { :type => 'WTFPL', :file => 'LICENSE' }
  s.author           = { 'Jo Brunner' => 'jo@mett.io' }
  s.source           = { :git => 'https://github.com/jobrunner/MayISBN.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '8.0'
  s.source_files = 'MayISBN/*.{h,m}'
 
end
