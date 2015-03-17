Pod::Spec.new do |s|
  s.name             = "BTKCollectionViewFlowLayout"
  s.version          = "1.0.0"
  s.summary          = "CollectionViewFlowLayout which supports alignment and sticky view"
  s.description      = <<-DESC
                       CollectionViewFlowLayout which supports alignment and sticky view
                       DESC
  s.homepage         = "https://github.com/tomohisaota/BTKCollectionViewFlowLayout"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "Tomohisa Ota" => "tomohisa.ota+github@gmail.com" }
  s.source           = { :git => "https://github.com/tomohisaota/BTKCollectionViewFlowLayout.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/toowitter'

  s.ios.deployment_target = '6.0'
  s.requires_arc = true

  s.source_files = 'Classes/**/*.{h,m}'

end
