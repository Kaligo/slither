class Slither
  class Generator
    def initialize(definition, trailing_newline = false)
      @definition = definition
      @generator_should_add_trailing_newline = trailing_newline
      @force_generator_to_add_newline = definition.options[:trailing_newline]
    end

    def generate(data)
      @builder = []
      @definition.sections.each do |section|
        content = data[section.name]
        raise(Slither::RequiredSectionEmptyError, "Required section '#{section.name}' was empty.") if !content&.any? && !section.optional

        content = [content] if content.is_a?(Hash)
        content&.each do |row|
          @builder << section.format(row)
        end
      end
      generate_file_output
    end

    private

    def generate_file_output
      output = @builder.join("\n")
      output.concat("\n") if add_trailing_newline?
      output
    end

    def add_trailing_newline?
      return true if @force_generator_to_add_newline
      @generator_should_add_trailing_newline
    end
  end
end
