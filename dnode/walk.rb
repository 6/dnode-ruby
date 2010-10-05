class Walk
    def initialize obj
        @path = []
        @object = obj
    end
    
    def walk &block
        _walk(@object, block)
    end
    
    def _walk obj, cb
        node = Node.new(:value => obj, :path => @path)
        cb.call(node)
        value = node.value
        
        if value.is_a? Hash then
            copy = {}
            value.each do |key,v|
                @path.push key
                copy[key] = _walk(v, cb)
                @path.pop
            end
            return copy
        elsif value.is_a? Array then
            copy = []
            value.each_with_index do |v,i|
                @path.push i
                copy.push(_walk(v, cb))
                @path.pop
            end
            return copy
        elsif [ Numeric, String, Proc ].select{ |x| value.is_a? x }.any?
            return value
        else
            # only serve up the object's "own" methods
            return value.methods.select { |name|
                value.method(name).owner == value.class
            }.inject({}) { |acc,name|
                acc.merge(name => value.method(name).to_proc)
            }
        end
    end
    private :_walk
end

class Node
    def initialize params
        @value = params[:value]
        @path = params[:path]
    end
    
    attr_accessor :value
    
    def update value
        @value = value
    end
    
    attr_reader :path
end
