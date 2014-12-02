
Pod::Spec.new do |s|
  s.name         = "YYHModelRouter"
  s.version      = "0.0.1"
  s.summary      = "A lightweight utility built on top of AFNetworking for interacting with model objects over RESTful HTTP services."
  s.description  = <<-DESC
                   A lightweight utility built on top of AFNetworking for interacting with model objects over RESTful HTTP services.
                   Provides endpoint-based configuration for automatically serializing JSON request/response payloads into model objects. By default [Mantle](https://github.com/Mantle/Mantle) is used to serialize model objects but custom model serializers can easily be built to work with any model framework.
                   DESC
  s.homepage     = "https://github.com/yayuhh/YYHModelRouter"
  s.license      = "MIT"
  s.author             = { "Angelo Di Paolo" => "angelod101@gmail.com" }
  s.social_media_url   = "http://twitter.com/angelodipaolo"
  s.platform     = :ios, "7.0"
  s.osx.deployment_target = "10.9"
  s.source       = { :git => "https://github.com/yayuhh/YYHModelRouter.git", :tag => "0.0.1" }
  s.source_files  = "YYHModelRouter/*.{h,m}"
  s.dependency "AFNetworking", "~> 2.5"

  s.subspec 'core' do |core|
    core.source_files = "YYHModelRouter/*.{h,m}"
  end

  s.subspec 'mantle' do |mantle|
    mantle.dependency 'YYHModelRouter/core'
    mantle.dependency "Mantle", "~> 1.5"
    mantle.source_files = "Serializers/Mantle/**/*.{h,m}"
  end
end
