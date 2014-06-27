workspace './MSSDataServices'
xcodeproj 'Example/MSSDataServices Example'
xcodeproj 'Specs/MSSDataServices Spec'

target 'MSSDataServices Example' do
  xcodeproj 'Example/MSSDataServices Example'

  platform :ios, '6.0'
  link_with 'MSSDataServices Example'
  pod 'MSSDataServices', :path => './'
end

target 'MSSDataServicesSpecs' do
    xcodeproj 'Specs/MSSDataServices Spec'
    
    platform :ios, '7.0'
    link_with 'MSSDataServicesSpecs'
    pod 'Kiwi/XCTest'
    pod 'MSSDataServices', :path => './'
end
