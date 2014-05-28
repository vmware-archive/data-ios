workspace './PCFDataServices'
xcodeproj 'Example/PCFDataServices Example'
xcodeproj 'Specs/PCFDataServices Spec'

target 'PCFDataServices Example' do
  xcodeproj 'Example/PCFDataServices Example'

  platform :ios, '6.0'
  link_with 'PCFDataServices Example'
  pod 'PCFDataServices', :path => './'
end

target 'PCFDataServicesSpecs' do
    xcodeproj 'Specs/PCFDataServices Spec'
    
    platform :ios, '7.0'
    link_with 'PCFDataServicesSpecs'
    pod 'Kiwi/XCTest'
    pod 'PCFDataServices', :path => './'
end