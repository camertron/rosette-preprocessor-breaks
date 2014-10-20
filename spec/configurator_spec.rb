# encoding: UTF-8

require 'spec_helper'

include Rosette::Preprocessors

describe BreakPreprocessor::Configurator do
  let(:configurator) { BreakPreprocessor::Configurator.new }

  describe '#applies_to?' do
    it 'sets applies_to_proc' do
      configurator.applies_to? { :applies_to }
      expect(configurator.applies_to_proc).to_not be_nil
      expect(configurator.applies_to_proc.call).to eq(:applies_to)
    end
  end

  describe '#set_boundary_type' do
    it 'sets the boundary type in the configurator' do
      configurator.set_boundary_type(:word)
      expect(configurator.boundary_type).to eq(:word)
    end

    it "raises an error if the boundary type isn't supported" do
      expect { configurator.set_boundary_type(:foobar) }.to(
        raise_error(ArgumentError)
      )
    end
  end

  describe '#set_delimiter' do
    it 'accepts the :pilcrow symbol as a delimiter' do
      configurator.set_delimiter(:pilcrow)
      expect(configurator.delimiter).to eq("\u00B6")
    end

    it 'accepts the :zero_width_space symbol as a delimiter' do
      configurator.set_delimiter(:zero_width_space)
      expect(configurator.delimiter).to eq("\u200B")
    end

    it 'accepts a string as a delimiter' do
      configurator.set_delimiter('abc')
      expect(configurator.delimiter).to eq('abc')
    end

    it "raises an error if the given symbol isn't a supported delimiter" do
      expect { configurator.set_delimiter(:foobar) }.to(
        raise_error(ArgumentError)
      )
    end

    it "raises an error if the delimiter isn't a string or symbol" do
      expect { configurator.set_delimiter(1) }.to(
        raise_error(ArgumentError)
      )
    end
  end
end
