class Scrub
    def initialize
        @callbacks = {}
    end
    
    def scrub args
        { :object => args, :callbacks => {} }
    end
    
    def unscrub req
        # yield
        req['arguments']
    end
end
