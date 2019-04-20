Pod::Spec.new do |s|
    s.name         = 'RROLoadSwizzle'
    s.version      = '1.0.0'
    s.summary      = 'Simple NSObject category for swizzle method implementation and revert to the original'
    s.homepage = "https://github.com/remirobert/RROLoadSwizzle"
    s.license      = 'MIT'
    s.author       = { 'Remi ROBERT' => 'remirobert33530@gmail.com' }
    s.source       = { :git => 'https://github.com/remirobert/RROLoadSwizzle', :tag => s.version }

    s.source_files = 'RROLoadSwizzle/**/*.{h,m}'
    s.private_header_files = 'RROLoadSwizzle/RROSwizzlingInfoStore.h'
    s.requires_arc = true

    s.ios.deployment_target = '10.0'
    s.ios.frameworks = 'Foundation'
end
