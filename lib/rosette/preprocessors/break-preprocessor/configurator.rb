# encoding: UTF-8

module Rosette
  module Preprocessors
    class BreakPreprocessor

      class Configurator
        attr_reader :applies_to_proc, :delimiter, :boundary_type

        DELIMITER_MAP = {
          pilcrow: "\u00B6",
          zero_width_space: "\u200B"
        }

        VALID_BOUNDARY_TYPES = [:word, :line, :sentence]
        DEFAULT_BOUNDARY_TYPE = :word

        def initialize
          @boundary_type = DEFAULT_BOUNDARY_TYPE
        end

        # Does the object passed to this block
        # qualify for pre-processing? You decide.
        def applies_to?(&block)
          @applies_to_proc = block
        end

        def set_boundary_type(boundary_type)
          if VALID_BOUNDARY_TYPES.include?(boundary_type)
            @boundary_type = boundary_type
          else
            raise ArgumentError,
              "Invalid boundary type '#{boundary_type}'. Options are #{VALID_BOUNDARY_TYPES.inspect}."
          end
        end

        def set_delimiter(delim)
          @delimiter = case delim
            when Symbol
              # should raise an error if the key can't be found
              unless DELIMITER_MAP.include?(delim)
                raise ArgumentError,
                  "Unknown delimiter '#{delim}'. Options are #{DELIMITER_MAP.keys.inspect}."
              end

              DELIMITER_MAP[delim]

            when String
              delim
          end
        end

        def has_delimiter?
          !!delimiter
        end
      end

    end
  end
end
