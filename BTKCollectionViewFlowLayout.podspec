Pod::Spec.new do |s|
  s.name             = "BTKCollectionViewFlowLayout"
  s.version          = "1.1.4"
  s.summary          = "CollectionViewFlowLayout with additional supplemental views and alignment/sticky option."
  s.description      = <<-DESC
                       CollectionViewFlowLayout with body and background supplemental views.
                       Also have sticky header/footer option, and alignment option for items.
                       DESC
  s.homepage         = "https://github.com/tomohisaota/BTKCollectionViewFlowLayout"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "Tomohisa Ota" => "tomohisa.ota+github@gmail.com" }
  s.source           = { :git => "https://github.com/tomohisaota/BTKCollectionViewFlowLayout.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/toowitter'

  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'Classes/**/*.{h,m}'

end
