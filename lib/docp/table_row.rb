module Docp
  class TableRow
    extend Forwardable
    include Enumerable
    def_delegators :@row, :empty?, :any?, :count
    def_delegators :@tr, :at, :search, :elements, :row_elements
    attr_reader :tr
    attr_reader :formats
    def initialize tr, header_parser
      @tr = tr
      @row = row_elements.select {|td| td[:class] }
      @no_hash_keys = header_parser.no_hash_keys
      @after_to_hash = header_parser.after_to_hash
      @formats = {}
      header_parser.columns.each {|col|
        [col, col.children].flatten.each {|ch|
          if @tr[:class] == "table-header"
            @formats[ch.name] = format(self[ch.name], :text)
          else
            @formats[ch.name] = format(self[ch.name], ch.format)
          end
        }
      }
    end

    def [] name
      ret = case name
            when Symbol, String
              name = name.to_s if name.is_a?(Symbol)
              @row.find {|r| 
                r[:class] == name || r[:class].split(',').map {|cl| cl == name}.any?
              }
            else
              @row[name]
            end
      if ret
        ret
      else
        doc = Nokogiri::HTML::DocumentFragment.parse ""
        Nokogiri::XML::Element.new "td", doc
      end
    end

    def format td, format
      if format.is_a?(Symbol)
        td.send(format)
      elsif format.is_a?(Proc)
        par = format.parameters.map(&:last).map 
        if par.include?(:formats)
          -> { format.call(*par.map {|name| name == :row ? self : eval(name.to_s) })  }
        else
          format.call(*par.map{|name| name == :row ? self : eval(name.to_s) }) 
        end
      else
        format
      end
    end

    def each
      @row.each {|td| yield td}
    end

    def to_hash
      ret = {}
      @formats.each {|k, v|
        next if @no_hash_keys.include?(k)
        ret[k] = v.is_a?(Proc) ? v.call : v 
      }
      @after_to_hash.call(ret, self) if @after_to_hash
      ret
    end
  end
end
