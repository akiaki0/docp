module Docp
  class TableDoc
    include Enumerable
    attr_reader :doc, :tables
    def initialize
      @doc = Nokogiri::HTML::DocumentFragment.parse ""
      @tables = []
    end

    def parse parse_doc, header_parser, &block
      Docp::Table.find(parse_doc, header_parser) do|table, header_tr, header_index|
        @tables << Docp::Table.new(@doc, header_parser, table, header_tr, header_index)
        block.call @tables.last if block_given?
      end
      self
    end

    def each
      @tables.each {|table| yield table }
    end

    def rows &block
      @tables.map(&:rows).flatten.map {|row|
        yield row if block_given? 
        row
      }
    end

    def header_required_undefineds
      @tables.map(&:header_required_undefineds).compact
    end

    def empty?
      @tables.empty?
    end

    def any?
      @tables.any?
    end
  end
end
