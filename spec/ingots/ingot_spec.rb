# spec/ingots/ingot_spec.rb

require 'spec_helper'

require 'controllers/abstract_controller'
require 'ingots/ingots'

describe Mithril::Ingots::Ingot do
  describe "initialisation" do
    let :module_key do :space_paranoids; end
    let :controller do Mithril::Controllers::AbstractController; end
    let :params     do {}; end

    it { expect { described_class.new }.to raise_error ArgumentError,
      /wrong number of arguments/i }

    it { expect { described_class.new(module_key) }.to raise_error ArgumentError,
      /wrong number of arguments/i }

    it { expect { described_class.new(module_key, controller) }.not_to raise_error }

    it { expect { described_class.new(module_key, controller, params) }.not_to raise_error }
  end # describe
  
  context do
    let :module_key do :space_paranoids; end
    let :controller do Mithril::Controllers::AbstractController.new; end
    
    let :instance do described_class.new(module_key, controller); end
    
    describe :key do
      it { instance.should respond_to :key }
      it { expect { instance.key }.not_to raise_error }
      it { instance.key.should == module_key }
    end # describe key
    
    describe :controller do
      it { instance.should respond_to :controller }
      it { expect { instance.controller }.not_to raise_error }
      it { instance.controller.should be controller }
    end # describe controller

    describe :name do
      it { instance.should respond_to :name }
      it { expect { instance.name }.not_to raise_error }
      it { instance.name.should == module_key.to_s.gsub('_',' ') }

      context "overriden" do
        let :module_name do "defend the grid"; end
        let :instance do described_class.new(module_key, controller, :name => module_name); end

        it { instance.name.should == module_name }
      end # context
    end # describe name
    
    describe "self.create" do
      after :each do
        Mithril::Ingots::Ingot.instance_variable_set :@modules, nil
      end # after each

      let :module_key do :space_paranoids; end
      let :controller do Mithril::Controllers::AbstractController.new; end
      let :params     do {}; end

      it { described_class.should respond_to :create }

      it { expect { described_class.create }.to raise_error ArgumentError,
        /wrong number of arguments/i }

      it { expect { described_class.create(module_key) }.to raise_error ArgumentError,
        /wrong number of arguments/i }

      it { expect { described_class.create(module_key, controller) }.not_to raise_error }

      it { expect { described_class.create(module_key, controller, params) }.not_to raise_error }

      it { described_class.create(module_key, controller).should be_a described_class }
    end # describe

    describe "self.all" do
      it { described_class.should respond_to :all }

      it { expect { described_class.all }.not_to raise_error }

      it { described_class.all.should == {} }
    end # describe
    
    describe "self.exists?" do
      let :module_key do :space_paranoids; end

      it { described_class.should respond_to :exists? }

      it { expect { described_class.exists? }.to raise_error ArgumentError,
        /wrong number of arguments/i }

      it { expect { described_class.exists?(module_key) }.not_to raise_error }

      it { described_class.exists?(module_key).should be false }
    end # describe
    
    describe "self.find" do
      let :module_key  do :space_paranoids; end
      let :module_name do "Space Paranoids"; end

      it { described_class.should respond_to :find }
      it { expect { described_class.find }.to raise_error ArgumentError,
        /wrong number of arguments/i }
      it { expect { described_class.find(module_key) }.not_to raise_error }
      it { expect { described_class.find(module_name) }.not_to raise_error }
      it { described_class.find(module_key).should be nil }
      it { described_class.find(module_name).should be nil }
    end # describe
  end # context
  
  context "with defined modules" do
    def self.module_keys
      [ :disc_wars, :light_cycles, :space_paranoids ]
    end # self.module_keys
    
    before :each do
      Mithril::Mock.const_set :MockDiscWarsController,
        Class.new(Mithril::Controllers::AbstractController)
      Mithril::Mock.const_set :MockLightCyclesController,
        Class.new(Mithril::Controllers::AbstractController)
      Mithril::Mock.const_set :MockSpaceParanoidsController,
        Class.new(Mithril::Controllers::AbstractController)
      
      described_class.create :disc_wars,       Mithril::Mock::MockDiscWarsController
      described_class.create :light_cycles,    Mithril::Mock::MockLightCyclesController
      described_class.create :space_paranoids, Mithril::Mock::MockSpaceParanoidsController
    end # before each
    
    after :each do
      Mithril::Mock.send :remove_const, :MockDiscWarsController
      Mithril::Mock.send :remove_const, :MockLightCyclesController
      Mithril::Mock.send :remove_const, :MockSpaceParanoidsController
      
      Mithril::Ingots::Ingot.instance_variable_set :@modules, nil
    end # after each
    
    let :controllers do {
      :disc_wars       => Mithril::Mock::MockDiscWarsController,
      :light_cycles    => Mithril::Mock::MockLightCyclesController,
      :space_paranoids => Mithril::Mock::MockSpaceParanoidsController
    }; end # let

    describe "self.all" do
      it { described_class.all.should_not have_key :asteroids }

      module_keys.each do |key|
        it { described_class.all.should have_key key }
        it { described_class.all[key].should be_a described_class }

        context "key = #{key}" do
          let :instance do described_class.all[key]; end

          it { instance.key.should == key }
          it { instance.controller.should == controllers[key] }
        end # context
      end # each
    end # describe all
    
    describe "self.exists?" do
      it { described_class.exists?(:pong).should be false }
      
      module_keys.each do |key|
        it { described_class.exists?(key).should be true }
      end # each
    end # describe exists
    
    describe "self.find" do
      it { described_class.find(:pong).should be nil }
      
      module_keys.each do |key|
        it { described_class.find(key).should be_a described_class }
        
        context "key = #{key}" do
          let :instance do described_class.find(key); end
          
          it { instance.key.should == key }
          it { instance.controller.should == controllers[key] }
        end # context
      end # each
    end # describe find
  end # context
end # describe
