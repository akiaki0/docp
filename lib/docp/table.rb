require 'docp/table_doc'
require 'docp/table_row'
require 'docp/table_remove_methods'

module Nokogiri
  class XML::Element
    def row_elements
      search('*').select {|el| ['td', 'th'].include?(el.name)}
#       [elements, search('*//td', '*//th')].sort {|a, b| a.count <=> b.count}[-1]
    end
  end
end

module Docp
  class Table
    class << self
      def parse parse_doc, header_parser, &block
        TableDoc.new.parse(parse_doc, header_parser, &block)
      end
      
      def find src_doc, header_parser
        header_parser = header_parser.is_a?(Hash) ? TableHeader.new(nil, header_parser) : header_parser
        src_doc = Nokogiri::HTML(src_doc) if src_doc.is_a?(String)
        parse_doc = src_doc.respond_to?(:to_html) ?  Nokogiri::HTML(src_doc.to_html) : Nokogiri::HTML(src_doc.parser.to_html)
        parse_doc.search('//table').each {|table, i|
          next if table.at('table') || table.at('tr table')
          table.search('tr').map.with_index do|tr, header_index|
            break if header_parser.exclude_ptn?(tr)
            next unless header_parser.include_ptn?(tr)
            next unless header_parser.required_all?(tr)
            yield table, tr, header_index
            break
          end
        }
      end
      
      def header_required_all? header_tr, header_parser

      end
    end

    extend TableRemoveMethods
    extend Forwardable
    include TableRemoveMethods
    include Enumerable
    class HeaderCountNotMatchError < StandardError; end
    class RequiredAttributesUndefined < StandardError; end

    def_delegators :@this_table, :at, :search, :elements, :row_elements
    attr_reader :doc
    attr_reader :header_required_undefineds
    def initialize doc, header_parser, table, header_tr, header_index
      @doc = doc
      @this_table = Nokogiri::XML::Element.new("table", @doc)
      @header_parser = header_parser.child || header_parser
      if @header_parser.columns.any?
        parse_table table, header_tr, header_index
      end
    end

    def parse_table table, header_tr, header_index
      @header_parser.before_parse.call(table) if @header_parser.before_parse
      doc_remove_attributes(table)
      if @header_parser.vertical
        header_tr = @this_table.add_child Nokogiri::XML::Element.new("tr", @doc)
        row_tr = @this_table.add_child Nokogiri::XML::Element.new("tr", @doc)
        header_tr[:class] = "table-header"
        table.row_elements.each do|td|
          if col = @header_parser.columns.find {|c| c.include_ptn?(td)}
            cltd = td.clone
            cltd[:class] = col.name
            header_tr.add_child cltd.clone
            if ntd = td.next_element
              ntd[:class] = ntd[:class] ? "#{ntd[:class]},#{col.name}" : col.name
              row_tr.add_child ntd.clone
            else
              #raise "NextElementNotfound #{ntd.class} #{ntd}\n"
            end
          end
        end
        #set_vertical_row_attributes(header_tr)
        @doc.add_child(@this_table)
      else
        #if header_required_all?(header_tr)
          if row_elements = table.search('tr')[header_index..-1]
            header_tr[:class] = "table-header"
            @this_table.add_child row_elements
            set_header_attributes(header_tr)
            set_row_attributes(header_tr, @this_table.search('tr')[1..-1])
            @doc.add_child(@this_table)
          end
        #end
      end
      self
    end

    def get_row_class_names tr_elements
      tr_elements.map {|td| 
        next unless td[:class]
        td[:class].split(",").map(&:to_sym)
      }.compact.flatten
    end

    def row_required_all? tr_elements
      ret = get_row_class_names(tr_elements).select {|name| @header_parser.required_keys.include?(name)}
      ret.count >= @header_parser.required_keys.count
    end

    def extend_row tr
      TableRow.new(tr, @header_parser)
    end
    
    def errors
      mes = @this_table.search('tr').map {|tr| tr[:error]}.compact
      mes
    end

    def each args = {}
      @this_table.search('tr').each {|tr|
        header = tr.at('.table-header')
        next if args[:header].nil? && tr[:class] == "table-header" 
        next if tr.row_elements.select {|td| td[:class]}.empty?
        yield extend_row(header) if args[:header]
        if row_required_all?(tr.row_elements)
          yield extend_row(tr)
        end
      }
    end

    def header
      #@this_table.at('.table-header')
      extend_row @this_table.at('.table-header')
    end

    def rows args = {}
      [].tap {|ret|
        each(args) {|row| 
          ret << row.tap {|r| yield r if block_given?} }
      }
    end

#     alias :rows :map
    alias :rows_each :each
    alias :rows_each_with_index :each_with_index

#     def set_vertical_row_attributes tr
#       tr.row_elements.each {|td|
#         @header_parser.columns.each do|col|
#           if col.include_ptn?(td)
#             if ntd = td.next_element
#               ntd[:class] = ntd[:class] ? "#{ntd[:class]},#{col.name}" : col.name
#             end
#           end
#         end
#       }
#     end

    def set_header_attributes tr
      tr.row_elements.each {|td|
        @header_parser.columns.each do|col|
          if col.include_ptn?(td)
            td[:class] = td[:class] ? "#{td[:class]},#{col.name}" : col.name
          end
        end
      }
    end

    def set_row_attributes header_tr, tr_rows
      tr_rows.each_with_index {|tr, i|
        if header_tr.row_elements.count != tr.row_elements.count
          tr[:error] = "#{HeaderCountNotMatchError}"
        end
        header_tr.row_elements.each_with_index do|h, x|
          next if h[:class].nil? || tr.row_elements[x].nil?
          tr.row_elements[x][:class] = h[:class] if h[:class]
        end
        unless row_required_all?(tr.row_elements)
          tr[:error] = "#{RequiredAttributesUndefined}" 
        end
      }
    end
  end
end
