Pod::Spec.new do |spec|
    spec.name = 'DFJPEGTurbo'
    spec.version = '1.0.0'
    spec.license = 'MIT'
    spec.homepage = 'https://github.com/kean/DFJPEGTurbo'
    spec.authors = 'Alexander Grebenyuk'
    spec.summary = 'Objective-C libjpeg-turbo wrapper'
    spec.source = {
        :git => 'https://github.com/kean/DFJPEGTurbo.git', 
        :tag => 'v1.0.0'
    }
    spec.source_files = 'DFJPEGTurbo/*'
    spec.requires_arc = true
end
