
Pod::Spec.new do |s|
    s.name             = 'ZDMediaPickerSDK'
    s.version          = '0.0.7'
    s.summary          = 'This media Picker allows picking Images, Videos, Live Photos and captures images and videos as well'

    s.description      = 'A Customized Media Picker which supports multiple selection using pan gesture and scrolls automatically on reaching top/bottom of the screen. It also supports custom previewing of image, video and live photo. Automatically resize the cells during orientation change. Supports separate album collections'

    s.homepage         = 'https://www.zoho.com'
    s.license          = { :type => 'MIT'}
    s.author           = { 'DeskMobile' => 'support@zohodesk.com' }
    s.source           = { :git => 'https://github.com/zoho/ZDMediaPickerSDK.git'}
    s.platform         = :ios, '10.0'

    s.source_files = 'native/ZDMediaPicker/ZDMediaPicker/**/*.{swift,h,m}'
    s.resources = 'native/ZDMediaPicker/ZDMediaPicker/**/*.{strings,xib,xcassets,strings,ttf,otf,css,js,html,storyboard,eot,svg,woff,xcdatamodeld,json,sh,rb,proto}'
    s.public_header_files = 'native/ZDMediaPicker/ZDMediaPicker/**/*.{h}'
    s.module_name = 'ZDMediaPickerSDK'
    s.swift_version = "5.0"

end


