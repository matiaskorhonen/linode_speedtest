# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "linode_speedtest/version"

Gem::Specification.new do |s|
  s.name        = "linode_speedtest"
  s.version     = LinodeSpeedtest::VERSION
  s.authors     = ["Matias Korhonen"]
  s.email       = ["matias@kiskolabs.com"]
  s.homepage    = "http://matiaskorhonen.fi"
  s.summary     = %q{Benchmark Linode datacenters}
  s.description = %q{A command line tool to find out which Linode datacenter is fastest for you.}

  s.rubyforge_project = "linode_speedtest"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]


  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"

  s.add_runtime_dependency "awesome_print", "~> 1.0.2"
  s.add_runtime_dependency "colored", "~> 1.2"
  s.add_runtime_dependency "filesize", "~> 0.0.2"
  s.add_runtime_dependency "nokogiri", "~> 1.5.0"
  s.add_runtime_dependency "progressbar", "~> 0.10.0"
  s.add_runtime_dependency "text-table", "~> 1.2.2"
end
