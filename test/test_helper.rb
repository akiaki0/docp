$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'docp'
require "minitest/reporters"
require 'date'
Minitest::Reporters.use!
require 'minitest/autorun'

module Nokogiri
  class XML::Element
    def to_date
      Date.parse(text) rescue nil
    end
  end
end

class DocpTestHelper < Minitest::Test
  def set_header type = nil
    if block_given?
      return Docp::TableHeader.new do|h|
        yield h
      end
    end
    case type
    when :vertical
      Docp::TableHeader.new do|h|
        h.vertical = true
        h.add user_name: "user_name"
        h.add user_id: "user_id"
        h.add user_age: /age/, format: -> td { td.text.to_i }
        h.add user_birthday: /birthday/, format: :to_date
      end
    when :normal_and_vertical
      Docp::TableHeader.new do|h|
        h.include_ptn = /user_name/, /company_name/
        h.match_block do|h, match|
          if match[:index] == 0 && match[:ptn] == /user_name/
            h.add user_name: "user_name"
            h.add user_id: "user_id"
            h.add user_age: /age/, format: -> td { td.text.to_i }
            h.add user_birthday: /birthday/, format: :to_date
          elsif match[:index] == 1 && match[:ptn] == /company_name/
            h.vertical = true
            h.add company_name: "company_name"
            h.add company_id: "company_id"
          end
        end
      end
    when :nested
      Docp::TableHeader.new do|h|
        h.include_ptn = /user_name/, /company_name/
        h.match_block do|h, match|
          if match[:index] == 0 && match[:ptn] == /user_name/
            h.add user_name: "user_name"
            h.add user_id: "user_id"
            h.add user_age: /age/, format: -> td { td.text.to_i }
            h.add user_birthday: /birthday/, format: :to_date
          elsif match[:index] == 1 && match[:ptn] == /company_name/
            h.vertical = true
            h.add company_name: "company_name"
            h.add company_id: "company_id"
          end
        end
      end
    when :duplicate_attributes
      Docp::TableHeader.new do|h|
        h.include_ptn = /user_name/, /company_name/
        h.match_block do|h, match|
          h.default_format = -> td { td.text.strip }
          if match[:index] == 0 && match[:ptn] == /user_name/
            h.add user_name: "user_name"
            h.add user_url: "user_name", format: -> td { td.at('a') }
            h.add user_id: "user_id"
            h.add user_age: /age/, format: -> td { td.text.to_i }
            h.add user_birthday: /birthday/, format: :to_date
          elsif match[:index] == 1 && match[:ptn] == /company_name/
            h.vertical = true
            h.add company_name: "company_name"
            h.add company_url: "company_name", format: -> td { td.at('a') }
            h.add company_id: "company_id"
          end
        end
      end
    when :header_count_not_match, nil
      Docp::TableHeader.new do|h|
        h.vertical = true if type == :vertical
        h.add user_name: "user_name"
        h.add user_id: "user_id"
        h.add user_age: /age/, format: -> td { td.text.to_i }
        h.add user_birthday: /birthday/, format: :to_date
      end
    end
  end
    
  def src type = nil
    table = {
      vertical: "
              <table>
                <tr><td>spam</td><td>user_name</td><td>user1</td></tr>
                <tr><td>user_id</td><td><td>1</td></tr>
                <tr><td>user_birthday</td><td>2000/12/01</td></tr>
                <tr><td>user_age</td><td>20</td></tr>
              </table>",
              
      normal: "
          <table>
            <tr><td>user_name</td><td>user_id</td><td>user_birthday</td><td>user_age</tr>
            <tr><td>user1</td><td>1</td><td>2000/12/01</td><td>20</td></tr>
          </table>",
      normal_and_vertical: "
          <table>
            <tr><td>user_name</td><td>user_id</td><td>user_birthday</td><td>user_age</tr>
            <tr><td>user1</td><td>1</td><td>2000/12/01</td><td>20</td></tr>
          </table>
          <table>
            <tr><td>company_name</td><td>company1</td></tr>
            <tr><td>company_id</td><td>1</td></tr>
          </table>
          ",
      nested: "
          <table>
            <tbody>
              <tr>
                <td>
                  <table>
                    <tbody>
                      <tr>
                        <th>company_name</th>
                        <td>company1</td>
                      </tr>
                      <tr>
                        <th>company_id</th>
                        <td>1</td>
                      </tr>
                      <tr>
                      </tr>
                    </tbody>
                  </table>
                </td>
              </tr>
            </tbody>
          </table>
      ",
      header_count_not_match: "
       <table>
           <tr><td>user_name</td><td>user_id</td></tr>
           <tr><td>user1</td><td>1</td><td>spam</td></tr>
        </table>
      ",
      header_index: "
        <table>
           <tr><td>Spam user_name </td></tr>
           <tr><td>user_name</td><td>user_id</td></tr>
           <tr><td>user1</td><td>1</td></tr>
        </table>
      ",
      duplicate_attributes: "
        <table>
            <tr>
              <td>user_name</td><td>user_id</td><td>user_birthday</td><td>user_age</td>
            </tr>
            <tr>
              <td>user1<a href='http://www.example.com'></a></td><td>1</td><td>2000/12/01</td><td>20</td>
            </tr>
        </table>
        <table>
            <tr>
              <td>company_name</td><td>company1<a href='http://www.example.com'></a></td>
              <td>company_id</td><td>1</td>
            </tr>
        </table>
      "
      
    }
    type ||= :normal
    "<html><body>#{table[type]}</body></html>"
  end
  
  def parse_table type=nil
    Docp::Table.parse(src(type), @header)
  end
end