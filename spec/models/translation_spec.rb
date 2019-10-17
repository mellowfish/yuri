require "spec_helper"
require_relative "../../app/models/translation.rb"

RSpec.describe Translation do
  TEST_CASES = [
    {
      ruby: "1 + 1",
      js: "1 + 1;"
    },
    {
      ruby: "puts \"hello world\"",
      js: "console.log('hello world');"
    },
    {
      ruby: "[1, 2].sum",
      js: "[1, 2].reduce((a, b) => a + b);"
    },
    {
      ruby: "a = 1 + 1",
      js: "var a = 1 + 1;"
    },
    {
      ruby: "[1, 2, 3].each { |number| puts number }",
      js: "[1, 2, 3].forEach((number) => console.log(number));"
    },
    {
      ruby: "[1, 2, 3].map { |number| number + 1 }",
      js: "[1, 2, 3].map((number) => number + 1);"
    }
  ].freeze

  subject do
    described_class.new(
      input_language: input_language,
      input_code: input_code,
      output_language: output_language
    )
  end

  describe "output_code" do
    context "from ruby to js" do
      let(:input_language) { "ruby" }
      let(:output_language) { "js" }

      TEST_CASES.each do |test_data|
        context "given: #{test_data[:ruby]}" do
          let(:input_code) { test_data[:ruby] }
          let(:output_code) { test_data[:js] }

          it "returns: #{test_data[:js]}" do
            expect(subject.output_code).to eq(output_code)
          end
        end
      end
    end

    context "from js to ruby" do
      let(:input_language) { "js" }
      let(:output_language) { "ruby" }

      TEST_CASES.each do |test_data|
        context "given: #{test_data[:js]}" do
          let(:input_code) { test_data[:js] }
          let(:output_code) { test_data[:ruby] }

          it "returns: #{test_data[:ruby]}" do
            expect(subject.output_code).to eq(output_code)
          end
        end
      end
    end
  end
end
