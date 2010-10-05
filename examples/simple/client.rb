require 'rubygems'
require 'dnode'

DNode.new({}).connect(5050) do |remote|
    remote.f(30000, proc { |x| puts "x=<#{x}>" })
end
