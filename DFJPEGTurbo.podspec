Pod::Spec.new do |spec|
    spec.name = 'DFJPEGTurbo'
    spec.version = '0.2.0'
    spec.summary = 'Objective-C libjpeg-turbo wrapper with baseline and progressive JPEG support'
    spec.ios.deployment_target = '6.0'
    spec.license = 'MIT'
    spec.homepage = 'https://github.com/kean/DFJPEGTurbo'
    spec.authors = 'Alexander Grebenyuk'
    spec.source = {
        :git => 'https://github.com/kean/DFJPEGTurbo.git', 
        :tag => spec.version.to_s
    }
    spec.source_files = 'DFJPEGTurbo/**/*.{h,m}'
    spec.vendored_libraries = 'DFJPEGTurbo/libturbojpeg/libturbojpeg.a'
    spec.requires_arc = true
end
