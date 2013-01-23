# spec/parsers/abstract_parser_helper.rb

require 'parsers/abstract_parser'

shared_examples_for Mithril::Parsers::AbstractParser do
  describe :parse_command do
    it { expect(instance).to respond_to :parse_command }
    it { expect { instance.parse_command }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { instance.parse_command "some text" }.not_to raise_error }
    it { expect(instance.parse_command "some_text").to be_a Array }
    it { expect(instance.parse_command("some_text").length).to be 2 }
  end # describe
end # describe
