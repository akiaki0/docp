require 'test_helper'

class TestPtn
  include Docp::TableHeaderPtn
end

class Docp::TableHeaderPtnTest < Minitest::Test
  def setup
    src = <<-EOS
      <html>
        <body>
        <table>
        <tr><td>user  name</td><td>user_id</td></tr>
        <tr><td>user1</td><td><td>1</td></tr>
        </table>
        </body>
      <html>
    EOS
    @test_doc = Nokogiri::HTML(src)
  end
  
  def test_ptn
    @ptn = TestPtn.new
    @ptn.include_ptn = "username"
    @ptn.exclude_ptn = "username"
    assert @ptn.include_ptn?(@test_doc.at('tr').search('*'))
    assert @ptn.exclude_ptn?(@test_doc.at('tr').search('*'))
    @ptn.after_check_val = -> el { el.text }
    assert !@ptn.include_ptn?(@test_doc.at('tr').search('*'))
  end
end
