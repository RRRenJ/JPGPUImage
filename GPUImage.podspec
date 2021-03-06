Pod::Spec.new do |s|
  s.name     = 'GPUImage'
  s.version  = '0.1.2'
  s.license  = 'BSD'
  s.summary  = 'An open source iOS framework for GPU-based image and video processing.'
  s.homepage = 'https://github.com/RRRenJ/JPGPUImage'
  s.author   = { 'RRRenj' => '584201474@qq.com' }
  s.source   = { :git => 'https://github.com/RRRenJ/JPGPUImage.git', :tag => "#{s.version}" }

  s.source_files = 'Source/**/*.{h,m}'
  s.resources = 'Resources/*.png'
  s.requires_arc = true
  s.xcconfig = { 'CLANG_MODULES_AUTOLINK' => 'YES' }
  
  s.ios.deployment_target = '8.0'
  s.ios.exclude_files = 'Source/Mac'
  s.ios.frameworks   = ['OpenGLES', 'CoreMedia', 'QuartzCore', 'AVFoundation']
  
  #s.osx.deployment_target = '10.6'
  #s.osx.exclude_files = 'framework/Source/iOS',
  #                      'framework/Source/GPUImageFilterPipeline.*',
  #                      'framework/Source/GPUImageMovieComposition.*',
  #                      'framework/Source/GPUImageVideoCamera.*',
  #                      'framework/Source/GPUImageStillCamera.*',
  #                      'framework/Source/GPUImageUIElement.*'
  #s.osx.xcconfig = { 'GCC_WARN_ABOUT_RETURN_TYPE' => 'YES' }
  
  
  
end
