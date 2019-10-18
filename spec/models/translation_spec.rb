require "spec_helper"
require_relative "../../app/models/translation.rb"

RSpec.describe Translation do
  TEST_CASES = [
    {
      ruby: "1 + 1",
      js: "1 + 1;",
      python3: "1 + 1"
    },
    {
      ruby: "puts \"hello world\"",
      js: "console.log('hello world');",
      python3: "print(\"hello world\")"
    },
    {
      ruby: "[1, 2].sum",
      js: "[1, 2].reduce((a, b) => a + b);",
      python3: "sum([1, 2])"
    },
    {
      ruby: "a = 1 + 1",
      js: "var a = 1 + 1;",
      python3: "a = 1 + 1"
    },
    {
      ruby: "[1, 2, 3].each { |number| puts number }",
      js: "[1, 2, 3].forEach((number) => console.log(number));",
      python3: "for number in [1, 2, 3]:\n"
    },
    {
      ruby: "[1, 2, 3].map { |number| number + 1 }",
      js: "[1, 2, 3].map((number) => number + 1);"
    },
    # TODO: JS -> RUBY not implemented
    # {
    #   ruby: "(1..100).each{ |i| puts([[\"Fizz\"][i % 3], [\"Buzz\"][i % 5]].compact.join.presence || i) }",
    #   js: "for(let i = 1; i < 100; i++) { console.log([['Fizz'][i % 3], ['Buzz'][i % 5]].filter((item) => item != null).join() || i) };"
    # }
  ].freeze

  subject do
    described_class.new(
      source_language: source_language,
      source_code: source_code,
      destination_language: destination_language
    )
  end

  describe "destination_code" do
    context "from ruby to js" do
      let(:source_language) { "ruby" }
      let(:destination_language) { "js" }

      TEST_CASES.each do |test_data|
        context "given: #{test_data[:ruby]}" do
          let(:source_code) { test_data[:ruby] }
          let(:destination_code) { test_data[:js] }

          it "returns: #{test_data[:js]}" do
            expect(subject.destination_code).to eq(destination_code)
          end
        end
      end
    end

    context "from js to ruby" do
      let(:source_language) { "js" }
      let(:destination_language) { "ruby" }

      TEST_CASES.each do |test_data|
        context "given: #{test_data[:js]}" do
          let(:source_code) { test_data[:js] }
          let(:destination_code) { test_data[:ruby] }

          it "returns: #{test_data[:ruby]}" do
            expect(subject.destination_code).to eq(destination_code)
          end
        end
      end
    end
  end
end
