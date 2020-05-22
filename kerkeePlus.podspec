
Pod::Spec.new do |spec|
 
  spec.name         = "kerkeePlus"
  spec.version      = "1.0.0"
  spec.summary      = "A short description of kerkeePlus."
  spec.description  = "kerkee的加强版，dek的部署封装"
  spec.homepage     = "http://www.kerkee.com"
  spec.license      = "GNU"
  spec.author             = { "zihong" => "zihong87@gmail.com" }
  spec.social_media_url   = "http://www.kerkee.com"
  spec.platform     = :ios, "8.0"
  #spec.source       = { :git => "/Users/zihong/Desktop/workspace/kercer/kerkeePlus_ios", :tag => "v1.0.1" }
  spec.source       = { :git => "https://github.com/kercer/kerkeePlus_ios.git", :tag => "v#{spec.version}", :submodules => true }#你的仓库地址，不能用SSH地址
  spec.source_files  = "kerkeePlus/**/*.{h,m}"
  spec.public_header_files = "kerkeePlus/**/*.h"
  spec.vendored_frameworks = "dependencies/*.framework"
  spec.dependency 'SSKeychain','~> 1.2.3'
  spec.dependency 'kerkee','~> 1.2.0'
  spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
