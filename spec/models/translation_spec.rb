require "spec_helper"
require "active_model"
require "active_support/all"
require_relative "../../app/models/translation.rb"

RSpec.describe Translation do
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

      context "simple code: 1 + 1" do
        let(:input_code) { "1 + 1" }
        let(:output_code) { "1 + 1;" }

        it "returns the code unmodified" do
          expect(subject.output_code).to eq(output_code)
        end
      end
    end
  end
end
