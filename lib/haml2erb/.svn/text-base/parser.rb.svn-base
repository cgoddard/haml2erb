require 'haml2erb/lexer'
require 'haml2erb/tokens'

module Haml2Erb
  class HamlParser

    ParsingError = Class.new(StandardError)

    def initialize
      @lexer = Haml2Erb::HamlLexer.new
    end

    def parse(unprocessed, writer)
      @line_number = 0
      # process incoming text one line at a time
      unprocessed.each_line do |line|
        @line_number += 1
        options = { }
        @lexer.load_input(line)

        # handle indent
        if(@lexer.peek(Haml2Erb::Tokens::Indent))
          options.merge!(@lexer.pop(Haml2Erb::Tokens::Indent).options)
        end
        options.merge!(:indent => 0) unless options[:indent]

        # handle initial tag attributes
        while(@lexer.peek(Haml2Erb::Tokens::InitialAttribute))
          options.merge!(@lexer.pop(Haml2Erb::Tokens::InitialAttribute).options)
        end
        options[:element_type] = :div if((options[:element_id] || options[:element_class]) && !options[:element_type])

        # handle interior element attributes
        if(@lexer.peek(Haml2Erb::Tokens::AttributesStart))
          @lexer.pop(Haml2Erb::Tokens::AttributesStart)
          options[:element_attributes] = { }
          while(!@lexer.peek(Haml2Erb::Tokens::AttributesEnd))
            if(@lexer.peek(Haml2Erb::Tokens::InnerAttributeQuoted))
              options[:element_attributes].merge!(@lexer.pop(Haml2Erb::Tokens::InnerAttributeQuoted).options[:element_attribute])
            elsif(@lexer.peek(Haml2Erb::Tokens::InnerAttributeRuby))
              options[:element_attributes].merge!(@lexer.pop(Haml2Erb::Tokens::InnerAttributeRuby).options[:element_attribute])
            elsif(@lexer.peek(Haml2Erb::Tokens::InnerAttributeNumber))
              options[:element_attributes].merge!(@lexer.pop(Haml2Erb::Tokens::InnerAttributeNumber).options[:element_attribute])
            else
              raise 'unrecognized inner attribute'
            end
          end
          @lexer.pop(Haml2Erb::Tokens::AttributesEnd)
        end

        # handle element contents
        if(@lexer.peek(Haml2Erb::Tokens::ContentsStart))
          options.merge!(@lexer.pop(Haml2Erb::Tokens::ContentsStart).options)
        end
        options[:content_type] = :text unless options[:content_type]

        if(@lexer.peek(Haml2Erb::Tokens::Contents))
          options.merge!(:contents => @lexer.pop(Haml2Erb::Tokens::Contents).matched)
        end

        writer << options
      end
    rescue => error
      raise ParsingError, "Haml2Erb had trouble parsing line #{@line_number} with input '#{@lexer.input}' remaining: #{error.to_s}"
    end
  end
end
