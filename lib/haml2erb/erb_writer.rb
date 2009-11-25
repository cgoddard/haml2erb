module Haml2Erb
  class ErbWriter

    def initialize
      @processed = ''
      @tag_stack = [ ]
    end

    def <<(line_options)

      close_tags(line_options[:indent])
      @tag_stack.push(line_options[:element_type]) if line_options[:element_type]

      @processed << ("  " * line_options[:indent]) if line_options[:indent]
      @processed << "<#{line_options[:element_type].to_s}" if line_options[:element_type]
      @processed << " id='#{line_options[:element_id].to_s}'" if line_options[:element_id]
      @processed << " class='#{line_options[:element_class].to_s}'" if line_options[:element_class]
      line_options[:element_attributes] && line_options[:element_attributes].keys.each do |attribute_key|
        @processed << " #{attribute_key}='#{line_options[:element_attributes][attribute_key]}'"
      end
      @processed << ">" if line_options[:element_type]

      case(line_options[:content_type])
      when :text
        @processed << (line_options[:contents] || "")
      when :ruby
        @processed << ("<%= " + line_options[:contents] + " %>")
      when :mixed
        @processed << ('<%= "' + line_options[:contents] + '" %>')
      end

      close_tags(line_options[:indent], :separate_line => false) if line_options[:contents]
      @processed << "\n"
    end

    def output_to_string
      close_tags(0)
      @processed
    end

    private

    def close_tags(current_indent, options = { :separate_line => true })
      while(@tag_stack.size > current_indent)
        @processed << ("  " * (@tag_stack.size - 1)) if options[:separate_line] == true
        @processed << "</#{@tag_stack.pop.to_s}>"
        @processed << "\n" if options[:separate_line] == true
      end
    end
  end
end