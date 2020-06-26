require_relative 'lib/ruby-go/version'

files = Dir.glob(Dir.pwd + '/**/*.rb')
files.collect! {|file| file.sub(Dir.pwd + '/', '')}
files.push('LICENSE', 'README.md', 'Rakefile', 'bin/rubygo')

Gem::Specification.new do |s|
  s.name        = 'ruby-go'
  s.version     = RubyGo::VERSION
  s.date        = "#{Time.now.strftime("%Y-%m-%d")}"
  s.homepage    = 'https://github.com/jphager2/ruby-go'
  s.summary     = 'The game of Go, writen in Ruby'
  s.description = 'A gem to play go and save games as sgf'
  s.authors     = ['jphager2']
  s.email       = 'jphager2@gmail.com'
  s.files       = files
  s.executables << 'rubygo'
  s.license     = 'MIT'

  s.add_runtime_dependency 'SgfParser', '~> 3.0.0'
  s.add_development_dependency 'rdoc'
end
