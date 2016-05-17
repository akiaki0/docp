require 'test_helper'

class Docp::TableHeaderTest < Minitest::Test
  def setup
    src = <<-EOS
      <html>
        <body>
        <table>
        <tr><td>user_name</td><td>user_id</td></tr>
        <tr><td>user1</td><td><td>1</td></tr>
        </table>
        </body>
      <html>
    EOS
    @test_doc = Nokogiri::HTML(src)
    @header = Docp::TableHeader.new do|h|
      h.required_attributes = :user_name
      h.add user_name: "user_name"
      h.add user_id: "user_id"
    end
  end
  
  def test_initialize
    assert @header.columns.any?
  end
  
  def test_elem_ptn
    assert @test_doc.search('tr').count > 1
    assert @header.include_ptn?(@test_doc.at('tr').search('*'))
    assert !@header.exclude_ptn?(@test_doc.at('tr').search('*'))
    
    @header.exclude_ptn = "user_name"
    assert @test_doc.search('tr').count > 1
    assert @header.include_ptn?(@test_doc.at('tr').search('*'))
    assert @header.exclude_ptn?(@test_doc.at('tr').search('*'))
  end
  
  def test_add_attributes
    @header = Docp::TableHeader.new do|h|
      h.required_attributes = :user_name
      h.add user_name: "user_name"
      h.add user_id: "user_id"
    end
    @header.add foo: "foo"
    assert_equal @header.columns.count, 3
    @header.required_attributes = :foo
    assert_equal @header.required_columns.count, 1
    assert_equal @header.columns.count, 3
    @header.required_attributes = nil
    assert_equal @header.required_columns.count, 0
  end
  
  def test_required
    assert @header.required_all?(@test_doc.at('tr'))
    @header.required_attributes = nil
    assert @header.required_columns.empty?
    assert @header.required_all?(@test_doc.at('tr'))
    @header.add required: "required"
    @header.required_attributes = :required
    assert_equal @header.required_all?(@test_doc.at('tr')), nil
  end
  

  def test_header_columns
  end
end
