# encoding: UTF-8

require 'spec_helper'

include Rosette::Core
include Rosette::Preprocessors

describe BreakPreprocessor do
  describe 'self#configure' do
    it 'yields a configurator and returns a preprocessor' do
      preprocessor = BreakPreprocessor.configure do |config|
        expect(config).to be_a(BreakPreprocessor::Configurator)
      end

      expect(preprocessor).to be_a(BreakPreprocessor)
    end
  end

  describe '#process_translation' do
    let(:config) { BreakPreprocessor::Configurator.new }
    let(:preprocessor) { BreakPreprocessor.new(config) }
    let(:en_phrase) { "I'm a little teapot" }
    let(:en_translation) { Translation.new(nil, :en, en_phrase) }
    let(:ja_phrase) { 'シニアソフトウェアエンジニア' }
    let(:ja_translation) { Translation.new(nil, :ja, ja_phrase) }
    let(:en_paragraph_lines) do
      [
        "Consider now provided laughter boy landlord dashwood. Often voice and the",
        "spoke. No showing fertile village equally prepare up people as an. That",
        "do an case an what plan hour of paid."
      ]
    end

    it 'creates a new translation object' do
      preprocessor.process_translation(en_translation).tap do |new_trans|
        expect(new_trans.object_id).to_not eq(en_translation.object_id)
      end
    end

    it "doesn't insert any delimiters if none is configured" do
      preprocessor.process_translation(en_translation).tap do |new_trans|
        expect(new_trans.translation).to eq(en_phrase)
      end
    end

    it 'inserts custom delimiters' do
      config.set_delimiter('|')

      preprocessor.process_translation(en_translation).tap do |new_trans|
        expect(new_trans.translation).to eq("I'm| |a| |little| |teapot")
      end
    end

    it 'inserts pilcrows' do
      config.set_delimiter(:pilcrow)

      preprocessor.process_translation(en_translation).tap do |new_trans|
        expect(new_trans.translation).to eq("I'm¶ ¶a¶ ¶little¶ ¶teapot")
      end
    end

    it 'inserts zero-width spaces' do
      config.set_delimiter(:zero_width_space)

      preprocessor.process_translation(en_translation).tap do |new_trans|
        expect(new_trans.translation).to eq(
          "I'm\u200B \u200Ba\u200B \u200Blittle\u200B \u200Bteapot"
        )
      end
    end

    context 'with a pipe delimiter' do
      before(:each) do
        config.set_delimiter('|')
      end

      it 'breaks japanese text' do
        preprocessor.process_translation(ja_translation).tap do |new_trans|
          expect(new_trans.translation).to eq('シニア|ソフトウェア|エンジニア')
        end
      end

      it 'breaks by sentence' do
        config.set_boundary_type(:sentence)
        translation = Translation.new(nil, :en, en_paragraph_lines.join)

        preprocessor.process_translation(translation).tap do |new_trans|
          expect(new_trans.translation).to eq(
            "Consider now provided laughter boy landlord dashwood. |Often voice and the" +
              "spoke. |No showing fertile village equally prepare up people as an. |That" +
              "do an case an what plan hour of paid."
          )
        end
      end

      it 'breaks by line (identifies good places to wrap)' do
        config.set_boundary_type(:line)

        preprocessor.process_translation(en_translation).tap do |new_trans|
          expect(new_trans.translation).to eq("I'm |a |little |teapot")
        end
      end
    end
  end
end
