module Haml2Erb
  module Tokens

    class Token
      attr_reader :options, :matched

      def initialize(matched, options = {})
        @matched = matched
        @options = options
      end

      def self.match(text)
        match_data = @regex.match(text)
        match_data ? self.new(match_data.to_s) : nil
      end
    end

    class Indent < Token
      @regex = /^(\s\s)+/

      def self.match(text)
        match_data = @regex.match(text)
        match_data ? self.new(match_data.to_s, :indent => (match_data.to_s.size / 2)) : nil
      end
    end

    class AttributesStart < Token
      @regex = /^\{\s*/
    end

    class AttributesEnd < Token
      @regex = /^\s*\}/
    end

    class ContentsStart < Token
      @regex = /^((\s+)|(==\s*)|(=\s*))/

      def self.match(text)
        match_data = @regex.match(text)
        if match_data
          @return_token = case match_data[1][0,1]
          when ' ' then self.new(match_data.to_s, :content_type => :text)
          when '='
            match_data[1][1,1] == '=' ? self.new(match_data.to_s, :content_type => :mixed) : self.new(match_data.to_s, :content_type => :ruby)
          end
        else
          @return_token = nil
        end
        @return_token
      end
    end

    class Contents < Token
      @regex = /^.+$/

      def self.match(text)
        text.gsub!(/\\\-/, "-")
        match_data = @regex.match(text)
        match_data ? self.new(match_data.to_s) : nil
      end
    end

    class InitialAttribute < Token
      @regex = /^([%#\.])(\w+)/

      def self.match(text)
        match_data = @regex.match(text)
        if match_data
          @return_token = case match_data[1]
          when '%' then self.new(match_data.to_s, :element_type => match_data[2])
          when '#' then self.new(match_data.to_s, :element_id => match_data[2])
          when '.' then self.new(match_data.to_s, :element_class => match_data[2])
          end
        else
          @return_token = nil
        end
        @return_token
      end
    end

    class InnerAttributeQuoted < Token
      @regex = /^,?\s*:?['"]?([\w-]+)['"]?(:|(\s*=>))\s*['"]([^'"]+)['"]\s*/
      def self.match(text)
        match_data = @regex.match(text)
        if(match_data) 
          value = match_data[4].gsub(/#\{([^\}]+?)\}/, '<%= \1 %>') # replace #{ value } with <%= value %>
          self.new(match_data.to_s, :element_attribute => { match_data[1] => value })
        else
          nil
        end
      end
    end

    class InnerAttributeRuby < Token
      @regex = /^,?\s*:?['"]?([\w-]+)['"]?(:|(\s*=>))\s*([^'"\s][^,\s]+)\s*/
      def self.match(text)
        match_data = @regex.match(text)
        match_data ? self.new(match_data.to_s, :element_attribute => { match_data[1] => "<%= #{match_data[4]} %>" }) : nil
      end
    end

    class InnerAttributeNumber < Token
      @regex = /^,?\s*:?['"]?([\w-]+)['"]?(:|(\s*=>))\s*(\d+)\s*/
      def self.match(text)
        match_data = @regex.match(text)
        match_data ? self.new(match_data.to_s, :element_attribute => { match_data[1] => match_data[4] }) : nil
      end
    end
  end
end
