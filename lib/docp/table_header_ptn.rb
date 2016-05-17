module Docp
  module TableHeaderPtn
    attr_accessor :include_ptn, :exclude_ptn
    attr_accessor :after_check_val
    def check_ptn elem, ptn
      text = after_check_val ? after_check_val.call(elem) : elem.text.del_space
      if ptn.is_a?(Regexp)
        text =~ ptn
      else
        [ptn].flatten.find {|v|
          if v.is_a?(Regexp)
            text =~ v
          else
            text == v
          end
        }
      end
    end

    def ptn? elems, ptn
      [elems].flatten.find {|el| check_ptn(el, ptn) }
    end
    
    def exclude_ptn? node
      ptn?(node, @exclude_ptn) if @exclude_ptn
    end
    
    def include_ptn? node
      ptn?(node, @include_ptn)
    end
  end
end
