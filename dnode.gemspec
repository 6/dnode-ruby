Gem::Specification.new do |s|
    s.name = 'dnode'
    s.version = '0.0.1'
    s.summary = 'Asynchronous remote method calls with transparently wrapped callbacks'
    s.require_paths = [ 'lib' ]
    s.files = [
        'LICENSE', 'lib/dnode.rb',
        Dir.glob('lib/dnode/*.rb'),
        Dir.glob('examples/**/*.rb'),
    ].flatten
    
    s.description = %q{
        With DNode you can tie together servers written in ruby, node.js, and
        perl.
        
        DNode is similar to DRb, but is asynchronous and transforms callbacks
        embedded in deeply nested structures.
    }
    s.authors = ['James Halliday']
    s.date = '2010-11-12'
    s.email = 'mail@substack.net'
    s.extra_rdoc_files = [ 'LICENSE' ]
    s.homepage = 'http://github.com/substack/dnode-ruby'
end
