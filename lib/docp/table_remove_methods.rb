module Docp
  module TableRemoveMethods
    def doc_remove_attributes(remove_doc)
      spam = "//*[contains(@style,'display:none')]"
      remove_doc.search(spam).remove
      remove_doc.search('tr', 'th', 'td').each do|row|
        row.attributes.each do|k, v|
          row.delete(k)
        end
      end
    end

    def colspan_join parse_doc
      parse_doc.search('tr').each_with_index {|tr, y|
        next_tr = tr.next_element
        tr.elements.each_with_index do|td, x|
          next if td[:colspan].nil? || next_tr.nil?
          col_depth = td[:colspan].to_i - 1
          col_depth.downto(0).map do|xx|
            next if next_tr.elements[xx].nil?
            td.next = next_tr.elements[xx].clone.tap {|e| 
              e.content = td.text + " " + next_tr.elements[xx].text
            }
            next_tr.elements[xx]
          end.compact.map(&:remove)
          td.remove
        end
        
#         tr.elements.each do|ch|
#           ch.attributes.each do|k, v|
#             ch.delete(k) if k=="colspan"
#           end
#         end
      }
    end

    def rowspan_join parse_doc
      parse_doc.search('tr').each_with_index {|tr, y|
        row_depth = 0
        no_rowspans = []
        tr.elements.each do|td|
          if td[:rowspan]
            row_depth = td[:rowspan].to_i-1
          else
            no_rowspans << td
          end
        end

        if row_depth > 0 
          row_depth.times do
            if tr.next_element
              tr.next_element.elements.each_with_index do|td, i|
                if no_rowspans[i]
                  no_rowspans[i].content = "#{no_rowspans[i].text} #{td.text}"
                else
                  tr.add_child td
                end
              end
              tr.next_element.remove
            end
          end
        end
      }
    end

    def rowspan_flatten parse_doc
      parse_doc.search('tr').each_with_index {|tr, y|
        row_depth = tr.elements.map {|td| td[:rowspan].to_i - 1 if td[:rowspan]}.compact.sort[-1]
        next if row_depth.nil?
        row_depth.times do
          if tr.next_element
            tr.add_child tr.next_element.elements
            tr.next_element.remove
          end
        end
      }
    end
  end
end
