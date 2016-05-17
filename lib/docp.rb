require 'forwardable'
require 'nokogiri'
require "docp/version"
require "docp/table_header"
require "docp/table"

class String
  def del_space
    gsub(/[[:space:][:cntrl:]]/, "")
  end
end

module Docp
  # Your code goes here...
end
