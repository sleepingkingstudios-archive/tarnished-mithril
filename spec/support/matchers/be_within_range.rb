# spec/support/matchers/be_within_range.rb

RSpec::Matchers.define :be_within_range do |min, max, params = {}|
  config = { :exclusive => false }
  config.update(params) if params.is_a? Hash
  
  match do |value|
    range = config[:exclusive] ? min...max : min..max
    range.include? value
  end # match
  
  failure_message_for_should do |value|
    "expected value #{value.inspect} to be between #{min} and #{max}"
  end # failure_message
  
  failure_message_for_should_not do |value|
    "expected value #{value.inspect} not to be between #{min} and #{max}"
  end # failure_message
end # define be_within_range
