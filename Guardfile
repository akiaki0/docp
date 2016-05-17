base = File.expand_path("../", __FILE__)

guard :minitest do
  watch(%r{^test/(.*)/?(.*)_test\.rb$}) {|m| "test/#{m[1]}_test.rb" }
  watch(%r{^lib/docp/(.*)\.rb$}) {|m| "test/#{m[1]}_test.rb" }
  
  watch(%r{^test/(.*)/integration/?(.*)_test\.rb$}) {|m| "test/#{m[1]}_test.rb" }
  watch(%r{^lib/docp/(.*)\.rb$}) { integration_tests() }
end

def integration_tests(resource = :all)
  if resource == :all
    Dir["test/integration/*"]
  else
    Dir["test/integration/#{resource}_*.rb"]
  end
end