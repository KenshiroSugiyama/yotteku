# -*- encoding: utf-8 -*-
# stub: firebase-auth-rails 0.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "firebase-auth-rails".freeze
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["penguinwokrs".freeze]
  s.date = "2019-06-21"
  s.description = "Description of Firebase::Auth::Rails.".freeze
  s.email = ["dev.and.penguin@gmail.com".freeze]
  s.homepage = "https://github.com/penguinwokrs/firebase-auth-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Summary of Firebase::Auth::Rails.".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.3.6"])
      s.add_development_dependency(%q<redis>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry-rails>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest-stub_any_instance>.freeze, [">= 0"])
      s.add_development_dependency(%q<minitest-retry>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<rails>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<firebase_id_token>.freeze, [">= 2.3.0", "~> 2.3"])
      s.add_runtime_dependency(%q<jwt>.freeze, [">= 2.1.0", "~> 2.1"])
    else
      s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3.6"])
      s.add_dependency(%q<redis>.freeze, [">= 0"])
      s.add_dependency(%q<pry-rails>.freeze, [">= 0"])
      s.add_dependency(%q<minitest-stub_any_instance>.freeze, [">= 0"])
      s.add_dependency(%q<minitest-retry>.freeze, [">= 0"])
      s.add_dependency(%q<rails>.freeze, [">= 0"])
      s.add_dependency(%q<firebase_id_token>.freeze, [">= 2.3.0", "~> 2.3"])
      s.add_dependency(%q<jwt>.freeze, [">= 2.1.0", "~> 2.1"])
    end
  else
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3.6"])
    s.add_dependency(%q<redis>.freeze, [">= 0"])
    s.add_dependency(%q<pry-rails>.freeze, [">= 0"])
    s.add_dependency(%q<minitest-stub_any_instance>.freeze, [">= 0"])
    s.add_dependency(%q<minitest-retry>.freeze, [">= 0"])
    s.add_dependency(%q<rails>.freeze, [">= 0"])
    s.add_dependency(%q<firebase_id_token>.freeze, [">= 2.3.0", "~> 2.3"])
    s.add_dependency(%q<jwt>.freeze, [">= 2.1.0", "~> 2.1"])
  end
end
