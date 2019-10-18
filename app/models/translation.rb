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
          /(?<expression>.+?)[.]sum/ => {
            code: "%<expression>s.reduce((a, b) => a + b)",
            keys: %w(expression)
          },
          /(?<expression>.+?)[.]compact/ => {
            code: "%<expression>s.filter((item) => item != null)",
            keys: %w(expression)
          },
          /(?<expression>.+?)[.](?<method_name>join)(?![(][)])/ => {
            code: "%<expression>s.%<method_name>s()",
            keys: %w(expression method_name)
          },
          /(?<expression>.+?)[.]presence/ => {
            code: "%<expression>s",
            keys: %w(expression)
          },
          /puts[ ](?<expression>.+)/ => {
            code: "console.log(%<expression>s)",
            keys: %w(expression)
          },
          /puts[(](?<expression>.+?)[)]/ => {
            code: "console.log(%<expression>s)",
            keys: %w(expression)
          },
          /[(](?<range_start>\d+)[.][.](?<range_end>\d+)[)][.]each[ ]?{[ ]?[|](?<block_argument>\w+)[|][ ]?(?<block_expression>.+?)[ ;]? }/ => {
            code: "for(let %<block_argument>s = %<range_start>s; %<block_argument>s < %<range_end>s; %<block_argument>s++) { %<block_expression>s }",
            keys: %w(range_start range_end block_argument block_expression)
          },
          /(?<expression>.+?)[.]each[ ]?{[ ]?[|](?<block_argument>\w+)[|][ ]?(?<block_expression>.+?)[ ;]? }/ => {
            code: "%<expression>s.forEach((%<block_argument>s) => %<block_expression>s)",
            keys: %w(expression block_argument block_expression)
          },
          /(?<expression>.+?)[.]map[ ]?{[ ]?[|](?<block_argument>\w+)[|][ ]?(?<block_expression>.+?)[ ;]? }/ => {
            code: "%<expression>s.map((%<block_argument>s) => %<block_expression>s)",
            keys: %w(expression block_argument block_expression)
          }
        },
        lines: {
          /^(?<variable_name>\w+)[ ]?=[ ]?(?<expression>.+)$/ => {
            code: "var %<variable_name>s = %<expression>s",
            keys: %w(variable_name expression)
          }
        }
      },
      python3: {
        expressions: {
          /puts[ ](?<expression>.+)/ => {
            code: "print(%<expression>s)",
            keys: %w(expression)
          },
          /puts[(](?<expression>.+?)[)]/ => {
            code: "print(%<expression>s)",
            keys: %w(expression)
          }
        }
      }
    },
    js: {
      ruby: {
        expressions: {
          /'(?<string>[^']+?)'/ => {
            code: "\"%<string>s\"",
            keys: %w(string)
          },
          /(?<expression>.+?)[.]reduce[(][(](?<a>\w+), (?<b>\w+)[)] => \k<a> [+] \k<b>[)]/ => {
            code: "%<expression>s.sum",
            keys: %w(variable_name expression)
          },
          /console[.]log[(](?<expression>.+?)[)]/ => {
            code: "puts %<expression>s",
            keys: %w(expression)
          },
          /(?<expression>.+?)[.]forEach[(][(](?<block_argument>\w+)[)] => (?<block_expression>.+?)[)]/ => {
            code: "%<expression>s.each { |%<block_argument>s| %<block_expression>s }",
            keys: %w(expression block_argument block_expression)
          },
          /(?<expression>.+?)[.]map[(][(](?<block_argument>\w+)[)] => (?<block_expression>.+?)[)]/ => {
            code: "%<expression>s.map { |%<block_argument>s| %<block_expression>s }",
            keys: %w(expression block_argument block_expression)
          }
        },
        lines: {
          /^var (?<variable_name>\w+)[ ]?=[ ]?(?<expression>.+)$/ => {
            code: "%<variable_name>s = %<expression>s",
            keys: %w(variable_name expression)
          }
        }
      }
    }
  }.freeze

  attr_accessor :source_code, :source_language, :destination_language

  def destination_code
    @destination_code ||=
      source_code.to_s.split("\n").map do |input_line|
        translate_line(input_line.strip)
      end.join("\n")
  end

  def source_output
    get_output(source_language, source_code)
  end

  def destination_output
    get_output(destination_language, destination_code)
  end

private

  def get_output(language, code)
    file = Tempfile.new("code.txt")
    case language
    when "ruby"
      file.write("require\"active_support\"\n")
      file.write("require\"active_support/all\"\n")
    end
    file.write(code)
    file.close

    execution_result = `#{code_runner(language)} #{file.path}`.gsub("\n", "<br>").html_safe

    return execution_result if $CHILD_STATUS == 0

    "Are you sure you know #{language}? git good n00b"
  ensure
    file.unlink
  end

  def code_runner(lang)
    case lang
    when "ruby"
      "ruby"
    when "js"
      "node"
    when "python3"
      "python"
    end
  end

  def mappings
    MAPPINGS.fetch(source_language.to_sym, {}).fetch(destination_language.to_sym, {})
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
      loop do
        another_please = false
        regex.match(line) do |match_data|
          line[regex] = format(mapping_data[:code], match_data.named_captures.slice(*mapping_data[:keys]).symbolize_keys)
          another_please = true
        end
        break unless another_please
      end
    end

    line_mappings.each do |regex, mapping_data|
      regex.match(line) do |match_data|
        line = format(mapping_data[:code], match_data.named_captures.slice(*mapping_data[:keys]).symbolize_keys)
      end
    end

    return "" if line.blank?

    if destination_language == "js"
      if line[-1] == ";"
        line
      else
        "#{line};"
      end
    else
      line
    end
  end
end
