require 'docp/table_header_ptn'
module Docp
  class TableHeader
    include TableHeaderPtn

    attr_reader :columns
    attr_reader :match_block
    attr_reader :child
    attr_accessor :required_attributes

    #TableOption
    attr_accessor :before_parse
    attr_accessor :vertical

    #RowOption
    attr_accessor :default_format
    attr_accessor :after_to_hash

    alias :required_keys :required_attributes

    def initialize match = nil, args = {}, &block
      @columns = []
      @required_columns = []
      @required_attributes = []
      args.each {|k, v| send("#{k}=", v) }
      @default_format ||= :text
      block.call(self, match)
      set_required_columns
    end

    def match_block &block
      @match_block = block if block_given?
      @match_block
    end

    #if match_block CreateSelfInstance & Schema == Child
    def include_ptn? tr
      [@include_ptn || @columns.map(&:include_ptn)].flatten.map.with_index do|ptn, i|
        if ptn?(tr.search('*'), ptn)
          match = {ptn: ptn, index: i, tr: tr}
          @child = TableHeader.new match, &@match_block if @match_block
          if @child
            return !@child.exclude_ptn?(tr.search('*'))
          else
            return true
          end
        end
      end.any?
    end

    def [] name
      name = name.to_sym if name.is_a?(String)
      @columns.find {|col| col.name == name}
    end

    def set_required_columns
      #keys = @required_attributes.select {|name| !@columns.find {|col| col.name == name} }
      #raise "Column NotFound #{keys}" if keys.any?
      if @required_attributes.any?
        @columns.select do|col|
          f = @required_attributes.find {|name| col.name == name}
          f ? col.required = true : col.required = false
        end
      else
        required_columns.map {|col| col.required = false }
      end
    end
    
    def required_attributes= names
      @required_attributes = [names].flatten.compact
      set_required_columns
    end
    
    def required_columns
      @columns.select {|col| col.required}
    end

    def required_all? tr
      return true if required_columns.empty?
      cols = required_columns.select {|col| col.include_ptn?(tr.row_elements) }
      if cols.count >= required_keys.count
        true
      else
        keys = required_keys.dup
        cols.each {|col| keys.delete(col.name)}
        #header_required_undefineds = { keys: keys, tr: tr.clone }
        nil
      end
    end

    def no_hash_keys
      @columns.select(&:no_hash).map(&:name)
    end

    def add h
      col = Column.new(h.merge(default_format: @default_format))
      yield col if block_given?
      @columns.push(*[col, col.children].flatten)
      col
    end

    def swap h
      col = Column.new(h.merge(default_format: @default_format))
      if i = @columns.index {|ch| ch.name == col.name}
        @columns[i] = col
      else
        raise ArgumentError, "#{col.name} ColumnNotFound"
      end
    end

    class Column
      include TableHeaderPtn
      attr_reader :name 
      attr_reader :include_ptn
      attr_reader :no_hash
      attr_reader :children
      
      attr_accessor :required
      attr_accessor :format
      def initialize hash
        @children = []
        @name, @include_ptn =  hash.shift
        @format = hash[:format] || hash[:default_format]
        @no_hash = hash[:no_hash]
      end

      def add name, hash
        @no_hash = true
        ch = Column.new( { name => nil, }.merge(hash) )
        @children << ch
      end
    end
  end
end
