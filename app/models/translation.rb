class Translation
  include ActiveModel::Model

  attr_accessor :input_code, :input_language, :output_language

  def output_code
    input_code.to_s.split("\n").map do |input_line|
      translate_line(input_line.strip)
    end.join("\n")
  end

  MAPPINGS = {
    /^puts[ \(]"(?<string>[^"]+?)"[\)]?$/ => {
      code: "console.log('%<string>s');",
      keys: %w(string)
    }
  }.freeze

  def translate_line(line)
    MAPPINGS.each do |regex, mapping_data|
      regex.match(line) do |match_data|
        return format(mapping_data[:code], match_data.named_captures.slice(*mapping_data[:keys]).symbolize_keys)
      end
    end

    line
  end
end
