# spec/support/matchers/include_matching.rb

RSpec::Matchers.define :include_matching do |regex|
  match do |enumerable|
    bool = false
    enumerable.each do |value|
      bool = true and next if value =~ regex
    end # each
    
    bool
  end # match
end # define include_matching
