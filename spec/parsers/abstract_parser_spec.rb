# spec/parsers/abstract_parser_spec.rb

require 'spec_helper'
require 'parsers/abstract_parser_helper'

require 'parsers/abstract_parser'

describe Mithril::Parsers::AbstractParser do
  let :instance do described_class.new; end
  
  it_behaves_like Mithril::Parsers::AbstractParser
end # describe
