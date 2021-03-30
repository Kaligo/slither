class Slither
  class Generator
    def initialize(definition)
      @definition = definition
    end

    def generate(data)
      @builder = []
      @definition.sections.each do |section|
        content = data[section.name]
        if content
          content = [content] if content.is_a?(Hash)
          raise(Slither::RequiredSectionEmptyError, "Required section '#{section.name}' was empty.") unless content.any?

          content.each do |row|
            @builder << section.format(row)
          end
        else
          unless section.optional
            raise(Slither::RequiredSectionEmptyError, "Required section '#{section.name}' was empty.")
          end
        end
      end
      @builder.join("\n")
    end
  end
end
