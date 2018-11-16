Pod::Spec.new do | spec |
  spec.name = "Teapot"
  spec.version = "2.0.0"
  spec.summary = "A light-weight URLSession wrapper for building simple API clients"
  spec.homepage = "https://github.com/elland/Teapot"
  spec.license = {type: 'MIT' }
  spec.authors = { "Igor Ranieri": "igor@elland.me" }

  spec.platform = ios: 10.0, mac: 10.11
  spec.requires_arc = true
  spec.source = { git: 'https://github.com/elland/Teapot.git', tag: "#{spec.version}" }
end
