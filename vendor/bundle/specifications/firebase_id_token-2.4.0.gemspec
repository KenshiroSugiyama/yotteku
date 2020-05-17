# -*- encoding: utf-8 -*-
# stub: firebase_id_token 2.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "firebase_id_token".freeze
  s.version = "2.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Fernando Schuindt".freeze]
  s.bindir = "exe".freeze
  s.date = "2020-05-02"
  s.description = "A Ruby gem to verify the signature of Firebase ID Tokens. It uses Redis to store Google's x509 certificates and manage their expiration time, so you don't need to request Google's API in every execution and can access it as fast as reading from memory.".freeze
  s.email = ["f.schuindtcs@gmail.com".freeze]
  s.homepage = "https://github.com/fschuindt/firebase_id_token".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "A Firebase ID Token verifier.".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.17", ">= 1.17.2"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 12.3", ">= 12.3.3"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<redcarpet>.freeze, [">= 3.4.0", "~> 3.4"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.14.1"])
      s.add_development_dependency(%q<codeclimate-test-reporter>.freeze, [">= 1.0.0", "~> 1.0"])
      s.add_development_dependency(%q<pry>.freeze, ["~> 0.12.2"])
      s.add_runtime_dependency(%q<redis>.freeze, ["~> 4.0", ">= 4.0.1"])
      s.add_runtime_dependency(%q<redis-namespace>.freeze, [">= 1.6.0", "~> 1.6"])
      s.add_runtime_dependency(%q<httparty>.freeze, ["~> 0.16", ">= 0.16.2"])
      s.add_runtime_dependency(%q<jwt>.freeze, [">= 2.1.0", "~> 2.1"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.17", ">= 1.17.2"])
      s.add_dependency(%q<rake>.freeze, ["~> 12.3", ">= 12.3.3"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<redcarpet>.freeze, [">= 3.4.0", "~> 3.4"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.14.1"])
      s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 1.0.0", "~> 1.0"])
      s.add_dependency(%q<pry>.freeze, ["~> 0.12.2"])
      s.add_dependency(%q<redis>.freeze, ["~> 4.0", ">= 4.0.1"])
      s.add_dependency(%q<redis-namespace>.freeze, [">= 1.6.0", "~> 1.6"])
      s.add_dependency(%q<httparty>.freeze, ["~> 0.16", ">= 0.16.2"])
      s.add_dependency(%q<jwt>.freeze, [">= 2.1.0", "~> 2.1"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.17", ">= 1.17.2"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.3", ">= 12.3.3"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<redcarpet>.freeze, [">= 3.4.0", "~> 3.4"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.14.1"])
    s.add_dependency(%q<codeclimate-test-reporter>.freeze, [">= 1.0.0", "~> 1.0"])
    s.add_dependency(%q<pry>.freeze, ["~> 0.12.2"])
    s.add_dependency(%q<redis>.freeze, ["~> 4.0", ">= 4.0.1"])
    s.add_dependency(%q<redis-namespace>.freeze, [">= 1.6.0", "~> 1.6"])
    s.add_dependency(%q<httparty>.freeze, ["~> 0.16", ">= 0.16.2"])
    s.add_dependency(%q<jwt>.freeze, [">= 2.1.0", "~> 2.1"])
  end
end
