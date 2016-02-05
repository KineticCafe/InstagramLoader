Pod::Spec.new do |s|

    s.name             = "KCInstagramLoader"
    s.version          = "0.0.1"
    s.summary          = "KCInstagramLoader is a simple tool to help you load Instagrams from given account"
    s.homepage         = "https://github.com/KineticCafe/InstagramLoader"
    s.license          = 'MIT'
    s.author           = { "Kinetic Cafe Inc." => "autobuild_kineticcafe@kineticcafe.com" }
    s.source           = { :git => "https://github.com/KineticCafe/InstagramLoader.git", :tag => s.version.to_s }

    s.ios.deployment_target = '7.0'
    s.osx.deployment_target = '10.10'
    s.requires_arc = true
    s.source_files = 'Pod/Classes/**/*.{h,m}'
    s.resources = 'Pod/Classes/KCInstagramLoader.xcdatamodeld'
    s.dependency 'AFNetworking', '~> 2.0'
end
