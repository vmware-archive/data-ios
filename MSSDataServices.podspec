Pod::Spec.new do |s|
  s.name     = 'MSSDataServices'
  s.version  = '0.1.0'
  s.license  = 'MIT'
  s.summary  = 'A OpenID Connect client framework for iOS.'
  s.homepage = 'https://github.com/cfmobile/data-ios.git'
  s.authors  = 'Elliott Garcea'
  s.source   = { :git => 'https://github.com/cfmobile/data-ios.git', :tag => "0.1.0" }
  s.requires_arc = true
  s.frameworks = 'SystemConfiguration', 'MobileCoreServices'

  s.ios.deployment_target = '6.0'
  s.dependency 'AFOAuth2Client'

  s.public_header_files = 'MSSDataServices/*.h'
  s.source_files = 'MSSDataServices/*.{h,m}'
end
