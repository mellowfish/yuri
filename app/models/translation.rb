class Translation
  include ActiveModel::Model

  MAPPINGS = {
    ruby: {
      js: {
        expressions: {
          /"(?<string>[^"]+?)"/ => {
            code: "'%<string>s'",
            keys: %w(string)
          },
          /^(?<expression>.+?)[.]sum$/ => {
            code: "%<expression>s.reduce((a, b) => a + b);",
            keys: %w(variable_name expression)
          },
        },
        lines: {
          /^puts[ (](?<expression>.+)[)]?$/ => {
            code: "console.log(%<expression>s)",
            keys: %w(expression)
          },
          /^(?<variable_name>\w+)[ ]?=[ ]?(?<expression>.+)$/ => {
            code: "var %<variable_name>s = %<expression>s",
            keys: %w(variable_name expression)
          },
        },
      }
    },
    js: {
      ruby: {
        expressions: {
          /'(?<string>[^']+?)'/ => {
            code: "\"%<string>s\"",
            keys: %w(string)
          },
          /^(?<expression>.+?)[.]reduce\(\(a, b\) => a [+] b\)$/ => {
            code: "%<expression>s.sum",
            keys: %w(variable_name expression)
          },
        },
        lines: {
          /^console[.]log[(](?<expression>.+?)[)]?$/ => {
            code: "puts %<expression>s",
            keys: %w(expression)
          },
          /^var (?<variable_name>\w+)[ ]?=[ ]?(?<expression>.+)$/ => {
            code: "%<variable_name>s = %<expression>s",
            keys: %w(variable_name expression)
          },
        }
      }
    }
  }.freeze

  attr_accessor :input_code, :input_language, :output_language

  def output_code
    input_code.to_s.split("\n").map do |input_line|
      translate_line(input_line.strip)
    end.join("\n")
  end

  def mappings
    MAPPINGS.fetch(input_language.to_sym, {}).fetch(output_language.to_sym, {})
  end

  def expression_mappings
    mappings.fetch(:expressions, {})
  end

  def line_mappings
    mappings.fetch(:lines, {})
  end

  def translate_line(line)
    line = line[0..-2] if line[-1] == ";"
    expression_mappings.each do |regex, mapping_data|
      regex.match(line) do |match_data|
        line[regex] = format(mapping_data[:code], match_data.named_captures.slice(*mapping_data[:keys]).symbolize_keys)
      end
    end

    line_mappings.each do |regex, mapping_data|
      regex.match(line) do |match_data|
        line = format(mapping_data[:code], match_data.named_captures.slice(*mapping_data[:keys]).symbolize_keys)
      end
    end

    return "" if line.blank?

    if output_language == "js"
      if line.last == ";"
        line
      else
        "#{line};"
      end
    else
      line
    end
  end
end
