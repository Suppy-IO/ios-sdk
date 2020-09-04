Pod::Spec.new do |s|
  s.name         = "SuppyConfig"
  s.version      = "1.0.11"
  s.summary      = "SuppyConfig allows you to manage frontend configurations in the suppy.io cloud."
  s.homepage     = "https://suppy.io"
  s.license      = { :type => "BSD-3", :file => "LICENSE.md" }
  s.author       = { "Ricardo Rautalahti-Hazan" => "ricardo@suppy.io" }
  s.platform     = :ios, "9.0"
  s.ios.deployment_target = '9.0'
  s.source       = { :git => "https://github.com/Suppy-IO/ios-sdk.git", :tag => s.version }
  s.source_files = 'SuppyConfig/**/*.swift'
  s.swift_version = '5'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.swift'
  end 
end

