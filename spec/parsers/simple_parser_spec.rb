# spec/parsers/simple_parser_spec.rb

require 'spec_helper'
require 'parsers/abstract_parser_helper'

require 'controllers/mixins/actions_base'
require 'parsers/simple_parser'

describe Mithril::Parsers::SimpleParser do
  let :actions do
    klass = Class.new
    klass.extend Mithril::Controllers::Mixins::ActionMixin
    klass.send :mixin, Mithril::Controllers::Mixins::ActionsBase
    klass.new
  end # let
  
  describe :initialize do
    it { expect { described_class.new }.to raise_error ArgumentError,
      /wrong number of arguments/i }
    it { expect { described_class.new nil }.to raise_error ArgumentError,
      /respond to \:has_action\?/i }
    it { expect { described_class.new actions }.not_to raise_error }
  end # describe
  
  context "initialized" do
    let :instance do described_class.new actions; end
    
    it_behaves_like Mithril::Parsers::AbstractParser

    describe :preprocess_input do
      let :output do "ooooooooooooooo"; end
      
      it { expect(instance.respond_to? :preprocess_input, true).to be true }
      it { expect { instance.send :preprocess_input }.to raise_error ArgumentError,
        /wrong number of arguments/i }
      it { expect { instance.send :preprocess_input, "" }.not_to raise_error }
      
      describe "strips leading and trailing whitespace" do
        let :input do "\n\t#{output}    \r"; end
        
        it { expect(instance.send(:preprocess_input, input)).to eq output }
      end # describe
      
      describe "downcases the input" do
        let :input do "oooOOOoooOOOooo"; end
        
        it { expect(instance.send(:preprocess_input, input)).to eq output }
      end # describe
      
      describe "normalises internal whitespace" do
        let :input do "#{output}  \r#{output}\n\t#{output}"; end
        
        it { expect(instance.send(:preprocess_input, input)).to eq "#{output} #{output} #{output}" }
      end # describe
      
      describe "strips punctuation" do
        let :input do "\"Bravely?\" Ha! Lily-livered; poultroon!" +
          " Coward's trousers, anointed. (person: scared [afraid])"; end
        let :output do "bravely ha lily livered poultroon cowards trousers" +
          " anointed person scared afraid"; end
        
        it { expect(instance.send(:preprocess_input, input)).to eq output }
      end # describe
    end # describe preprocess input
    
    describe :wordify do
      let :output do %w(second star to the right and straight on till morning); end
      
      it { expect(instance.respond_to? :wordify, true).to be true }
      it { expect { instance.send :wordify }.to raise_error ArgumentError,
        /wrong number of arguments/i }
      it { expect { instance.send :wordify, "" }.not_to raise_error }
      
      it { expect(instance.send(:wordify, output.join(" "))).to eq output }
      it { expect(instance.send(:wordify, output.join("\n"))).to eq output }
    end # describe wordify
    
    describe :parse_command do
      let :input do "Do Re Mi"; end

      it { expect(instance).to respond_to :parse_command }
      it { expect { instance.parse_command }.to raise_error ArgumentError,
        /wrong number of arguments/i }
      it { expect { instance.parse_command input }.not_to raise_error }
      
      it "preprocesses the text input" do
        instance.should_receive(:preprocess_input).with(input).and_call_original
        instance.parse_command input
      end # it
      
      context do
        before :each do
          actions.stub :has_action? do |key|
            [:do, :do_while, :do_not, :doo_wop].include? key
          end # stub
        end # before :each
        
        it do
          command, arguments = instance.parse_command("Don't stop believing!")
          expect(command).to be nil
        end # it
        
        it do
          command, arguments = instance.parse_command("Do you hear the people sing?")
          
          expect(command).to be :do
          expect(arguments).to eq %w(you hear the people sing)
        end # it

        it do
          command, arguments = instance.parse_command("Do, or do not. There is no try.")
          
          expect(command).to be :do
          expect(arguments).to eq %w(or do not there is no try)
        end # it
        
        it do
          command, arguments = instance.parse_command("Do while is a useful construct.")
          
          expect(command).to be :do_while
          expect(arguments).to eq %w(is a useful construct)
        end # it
      end # anonymous context
    end # describe parse_command
  end # context
end # describe
