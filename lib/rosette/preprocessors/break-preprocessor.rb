# encoding: UTF-8

require 'rosette/preprocessors'

java_import 'com.ibm.icu.util.ULocale'
java_import 'com.ibm.icu.text.BreakIterator'

module Rosette
  module Preprocessors

    class BreakPreprocessor < Preprocessor
      autoload :Configurator, 'rosette/preprocessors/break-preprocessor/configurator'

      DEFAULT_LOCALE = :en

      def self.configure
        config = Configurator.new
        yield config
        new(config)
      end

      def process_translation(translation)
        new_trans = process_string(
          translation.translation, translation.locale
        )

        translation.class.from_h(
          translation.to_h.merge(translation: new_trans)
        )
      end

      private

      def process_string(string, locale)
        segments = segment_text(
          string, locale || DEFAULT_LOCALE.to_s
        )

        segments.join(delimiter)
      end

      def delimiter
        if configuration.has_delimiter?
          configuration.delimiter
        else
          ''
        end
      end

      def segment_text(text, locale)
        brkiter = get_brkiter_instance(locale)
        brkiter.setText(text)
        start = brkiter.first
        segments = []

        until (stop = brkiter.next) == BreakIterator::DONE
          segments << text[start...stop]
          start = stop
        end

        segments
      end

      def get_brkiter_instance(locale)
        ulocale = ULocale.new(locale.to_s)

        case configuration.boundary_type
          when :word
            BreakIterator.getWordInstance(ulocale)
          when :line
            BreakIterator.getLineInstance(ulocale)
          when :sentence
            BreakIterator.getSentenceInstance(ulocale)
        end
      end

      def method_for(object)
        # determine if the object implements the translation interface
        is_trans = object.respond_to?(:translation) &&
          object.respond_to?(:locale) &&
          object.class.respond_to?(:from_h) &&
          object.respond_to?(:to_h)

        if is_trans
          :process_translation
        end
      end
    end

  end
end
