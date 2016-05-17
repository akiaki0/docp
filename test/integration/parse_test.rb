require 'test_helper'

class DocpParseTest < DocpTestHelper
  def parse_table type = nil
    @header = set_header(type)
    tdoc = Docp::Table.parse(Nokogiri::HTML(src(type)), @header)
    assert tdoc.rows.any?
    case type
    when :normal_and_vertical
      assert_equal tdoc.rows.count, 2
      tdoc.tables[0].header.tap do|header_row|
        h = header_row.to_hash
        assert_equal header_row.tr[:class], "table-header"
        assert_equal header_row[:user_name].text, "user_name"
        assert_equal h[:user_name], "user_name"
      end
      tdoc.tables[1].header.tap do|header_row|
        h = header_row.to_hash
        assert_equal header_row.tr[:class], "table-header"
        assert_equal header_row[:company_name].text, "company_name"
        assert_equal h[:company_name], "company_name"
      end
      hash = tdoc.rows.each_with_object({}) {|row, h|
        h.merge!(row.to_hash)
      }
      assert_equal hash[:user_name], "user1"
      assert_equal hash[:company_name], "company1"
    when :nested
      tdoc.tables[0].header.tap do|header_row|
        h = header_row.to_hash
        assert_equal header_row.tr[:class], "table-header"
        assert_equal header_row[:company_name].text, "company_name"
        assert_equal h[:company_name], "company_name"
      end
    else
      tdoc.tables[0].header.tap do|header_row|
        h = header_row.to_hash
        assert_equal header_row.tr[:class], "table-header"
        assert_equal header_row[:user_name].text, "user_name"
        assert_equal h[:user_name], "user_name"
      end
  
      tdoc.rows.each {|row|
        h = row.to_hash
        assert_equal row[:user_name].text, "user1"
        assert_equal h[:user_name], "user1"
        assert_equal h[:user_age], 20
        assert_equal h[:user_birthday], Date.parse("2000/12/01")
      }
    end
  end
  
  def test_required
    @header = set_header
    @header.required_attributes= :not_found_key
    tdoc = Docp::Table.parse(Nokogiri::HTML(src), @header)
    assert tdoc.rows.empty?
    @header.required_attributes = :user_name
    tdoc = Docp::Table.parse(Nokogiri::HTML(src), @header)
    assert tdoc.rows.any?
  end
  
  def test_find_table
    tables = []
    @header = set_header
    Docp::Table.find(Nokogiri::HTML(src), @header) {|t| tables << t}
    assert tables.any?
  end
  
  def test_normal_table_parse
    parse_table
  end
  
  def test_vertical_table_parse
    parse_table(:vertical)
  end
  
  def test_normal_and_vertical_parse
    parse_table(:normal_and_vertical)
  end
  
  def test_nested_table_parse
    parse_table(:nested)
  end
end
