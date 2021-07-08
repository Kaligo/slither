class Slither
  class Generator
    def initialize(definition)
      @definition = definition
    end

    def generate(data)
      @builder = []
      @definition.sections.each do |section|
        content = data[section.name]
        content = [content] if content.is_a?(Hash) || content.nil?
        raise(Slither::RequiredSectionEmptyError, "Required section '#{section.name}' was empty.") if !content || empty_required_content(content, section)

        if content.any?
          content.each do |row|
            @builder << section.format(row)
          end
        end
      end
      @builder.join("\n")
    end

    private

    def empty_required_content(content, section)
      content.none? && !section.optional
    end
  end
end
