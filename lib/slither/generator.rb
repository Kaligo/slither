class Slither
  class Generator
    def initialize(definition)
      @definition = definition
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
      @builder.join("\n")
    end
  end
end
