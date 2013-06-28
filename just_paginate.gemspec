# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "just_paginate"

Gem::Specification.new do |s|
  s.name        = "just_paginate"
  s.version     = JustPaginate::VERSION
  s.authors     = ["Gitorious AS"]
  s.email       = ["support@gitorious.org"]
  s.homepage    = "https://gitorious.org/gitorious/just_paginate"
  s.summary     = %q{Framework-agnostic support for paginating collections of things, and linking to paginated things in your webpage}
  s.description = %q{Framework-agnostic support for paginating collections of things, and linking to paginated things in your webpage}

  s.rubyforge_project = "just_paginate"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"

  s.add_development_dependency "minitest"
  if RUBY_VERSION.include?("1.8")
    # We must force the use of older gems that are compatible with this older
    # Ruby release.
    # The newer versions of shoulda pull in shoulda-matchers 2.2.0, which has
    # a hard dependency on Ruby 1.9.2.
    s.add_development_dependency "shoulda", "~> 3.3.2"
    # shoulda 3.3.2 depends on shoulda-matchers ~> 1.4.1, which in turn
    # depends on activesupport >= 3.0.0. Now that Rails 4 is released, Bundler
    # tries to pull in activesupport 4, which has a hard dependency on Ruby
    # 1.9.3.
    s.add_development_dependency "activesupport", "~> 3.0"
  else
    s.add_development_dependency "shoulda"
  end
  s.add_development_dependency "shoulda-context"
  s.add_development_dependency "rake"
end
