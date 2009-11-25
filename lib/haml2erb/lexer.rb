require 'haml2erb/tokens'

module Haml2Erb
  class HamlLexer

    attr_reader :input

    def load_input(text)
      @input = text
    end

    def peek(klass)
      #puts "peek #{klass} #{@input}"
      klass.match(@input)
    end

    def pop(klass)
      #puts "pop #{klass} #{@input}"
      token = klass.match(@input)
      @input.gsub!(/^#{Regexp.escape(token.matched)}/, '') # removed matched portion from the string
      token
    end

    def end_input?
      @input.strip.empty? ? true : false
    end
  end
end
