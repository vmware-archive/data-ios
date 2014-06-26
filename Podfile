workspace './PMSSDataServices'
xcodeproj 'Example/PMSSDataServices Example'
xcodeproj 'Specs/PMSSDataServices Spec'

target 'PMSSDataServices Example' do
  xcodeproj 'Example/PMSSDataServices Example'

  platform :ios, '6.0'
  link_with 'PMSSDataServices Example'
  pod 'PMSSDataServices', :path => './'
end

target 'PMSSDataServicesSpecs' do
    xcodeproj 'Specs/PMSSDataServices Spec'
    
    platform :ios, '7.0'
    link_with 'PMSSDataServicesSpecs'
    pod 'Kiwi/XCTest'
    pod 'PMSSDataServices', :path => './'
end
