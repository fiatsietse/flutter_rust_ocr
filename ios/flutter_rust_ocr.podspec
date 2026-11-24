Pod::Spec.new do |s|
  s.name             = 'flutter_rust_ocr'
  s.version          = '0.1.0'
  s.summary          = 'High-performance offline OCR plugin for Flutter powered by Rust.'
  s.description      = <<-DESC
A fast, offline, privacy-first cross-platform OCR engine for Flutter powered by Rust.
                       DESC
  s.homepage         = 'https://github.com/perso/flutter_rust_ocr'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Developers' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version    = '5.0'
end
