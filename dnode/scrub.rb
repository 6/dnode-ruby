require 'dnode/walk'

class Scrub
    def initialize
        @callbacks = {}
        @last_id = 0
    end
    
    def scrub args
        callbacks = {}
        walked = Walk.new(args).walk do |node|
            if node.value.is_a? Proc then
                id = @last_id
                @last_id += 1
                @callbacks[id] = node.value
                callbacks[id] = node.path
                node.value = '[Function]'
            end
        end
        { :object => walked, :callbacks => callbacks }
    end
    
    def unscrub req, &block
        Walk.new(req).walk do |node|
            id = @callbacks.detect{ |_,p| p == node.path }.first
            node.value = block.call(id) unless id.nil?
        end
    end
end
