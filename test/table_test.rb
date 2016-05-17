require 'test_helper'

class DocpTableTest < DocpTestHelper
  def test_parse_src_string_or_nokogiriHTML
    @header = set_header
    assert Docp::Table.parse("<html></html>", @header).is_a?(Docp::TableDoc)
    assert Docp::Table.parse(Nokogiri::HTML("<html></html"), @header).is_a?(Docp::TableDoc)
  end
  
  def test_header_count_not_match
    @header = set_header :header_count_not_match
    tdoc = parse_table :header_count_not_match
    assert tdoc.tables[0].errors.any?
    assert_equal tdoc.tables[0].errors[0], "#{Docp::Table::HeaderCountNotMatchError}"
    assert tdoc.rows.any?
    tdoc.rows.each do|row|
      row.search('tr').each {|tr|
        assert_equal tr[:error],  "#{Docp::Table::HeaderCountNotMatchError}"
      }
    end
  end
  
  def test_required
    @header = set_header
    tdoc = parse_table
    assert tdoc.rows.any?
    @header.required_attributes = :not_found
    tdoc = parse_table
    assert tdoc.rows.empty?
  end
  
  def test_include_and_execlude_ptn
    @header = set_header
    @header.include_ptn = /not_found/
    tdoc = parse_table
    assert tdoc.rows.empty?
    @header.include_ptn = //
    tdoc = parse_table
    assert tdoc.rows.any?
    @header.exclude_ptn = /user/
    tdoc = parse_table
    assert tdoc.rows.empty?
  end
  
  def test_header_index
    @header = set_header {|h|
      h.add user_name: /user_name/
      h.add user_id: "user_id"
    }
    tdoc = parse_table(:header_index)
    assert tdoc.rows.any?
    h = tdoc.rows[0].to_hash
    assert_equal h[:user_name], "user_name"
    
    @header.required_attributes = :user_id
    tdoc = parse_table(:header_index)
    assert tdoc.rows.any?
    h = tdoc.rows[0].to_hash
    assert_equal h[:user_name], "user1"
  end
  
  def test_duplicate_attributes
    @header = set_header(:duplicate_attributes)
    tdoc = parse_table(:duplicate_attributes)
    table = tdoc.tables[0]
    h = table.rows[0].to_hash
    assert_equal table.header[:user_name][:class], "user_name,user_url"
    assert_equal table.header[:user_url][:class], "user_name,user_url"
    assert_equal h[:user_name], "user1"
    assert h[:user_url].is_a?(Nokogiri::XML::Element)
    
    table = tdoc.tables[1]
    h = table.rows[0].to_hash
    assert_equal table.header[:company_name][:class], "company_name,company_url"
    assert_equal h[:company_name], "company1"
    assert h[:company_url].is_a?(Nokogiri::XML::Element)
  end
end
