workspace './PCFDataServices'
xcodeproj 'Example/PCFDataServices Example'
xcodeproj 'Specs/PCFDataServices Spec'

target 'PCFDataServices Example' do
  xcodeproj 'Example/PCFDataServices Example'

  platform :ios, '6.0'
  link_with 'PCFDataServices Example'
  pod 'AFOAuth2Client'
  pod 'google-plus-ios-sdk'
  pod 'PCFDataServices', :path => './'
end

target 'PCFDataServicesSpecs' do
    xcodeproj 'Specs/PCFDataServices Spec'
    
    platform :ios, '7.0'
    link_with 'PCFDataServicesSpecs'
    pod 'Kiwi/XCTest'
    pod 'AFOAuth2Client'
    pod 'PCFDataServices', :path => './'
end