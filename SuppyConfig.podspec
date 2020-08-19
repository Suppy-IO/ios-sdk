Pod::Spec.new do |s|

  s.name         = "SuppyConfig"
  s.version      = "1.0.0"
  s.summary      = "SuppyConfig allows you to manage frontend configurations in the Suppy.IO cloud."
  s.homepage     = "https://suppy.io"
  s.license      = { :type => "BSD", :file => "LICENSE.md" }
  s.author       = { "Ricardo Rautalahti-Hazan" => "ricardo@suppy.io" }
  s.platform     = :ios, "10.0"
  s.ios.deployment_target = '10.0'
  s.source       = { :git => "https://github.com/Suppy-IO/ios-sdk.git", :tag => s.version }
  s.source_files = 'SuppyConfig/**/*.swift'
  s.requires_arc = true
  s.swift_version = '4.2'

end

