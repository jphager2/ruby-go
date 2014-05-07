files = Dir.glob(Dir.pwd + '/**/*.rb')
files.collect! {|file| file.sub(Dir.pwd + '/', '')}
files -= files.select {|file| file =~ /scripts/}
files.push('LICENSE', 'README.md', 'Rakefile', 'bin/ruby-go.rb')

Gem::Specification.new do |s|
  s.name        = 'ruby-go'
  s.version     = '0.0.0'
	s.date        = "#{Time.now.strftime("%Y-%m-%d")}"
	s.homepage    = 'https://github.com/jphager2/gotasku'
  s.summary     = 'The game of Go, writen in Ruby'
  s.description = 'A gem to play go and save games as sgf'
  s.authors     = ['jphager2']
  s.email       = 'jphager2@gmail.com'
  s.files       = files 
  s.executables << 'ruby-go.rb'
  s.license     = 'MIT'
end
