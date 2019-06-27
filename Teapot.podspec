Pod::Spec.new do | spec |
  spec.name = "Teapot"
  spec.version = "2.2.0"
  spec.summary = "A light-weight URLSession wrapper for building simple API clients"
  spec.homepage = "https://github.com/bakkenbaeck/Teapot"
  spec.license = { type: 'MIT' }
  spec.authors = { "Igor Ranieri": "igor@elland.me" }

  spec.ios.deployment_target = '10.0'
  spec.requires_arc = true
  spec.source = { git: 'https://github.com/elland/Teapot.git', tag: "#{spec.version}" }
  spec.source_files = 'Teapot/*.swift'
  spec.swift_version = '4.2'
end
