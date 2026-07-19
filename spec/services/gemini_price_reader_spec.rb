require "rails_helper"

RSpec.describe GeminiPriceReader do
  describe "#call" do
    context "when no API key is configured" do
      before { allow(described_class).to receive(:configured?).and_return(false) }

      it "returns nil without calling the API" do
        reader = described_class.new("dummy")
        expect(reader).not_to receive(:extract_fields)
        expect(reader.call).to be_nil
      end
    end

    context "when an API key is configured" do
      before { allow(described_class).to receive(:configured?).and_return(true) }

      def call_with(fields)
        reader = described_class.new("dummy")
        allow(reader).to receive(:extract_fields).and_return(fields)
        reader.call
      end

      it "returns tax-included prices as-is" do
        expect(call_with({ "price" => 1760, "tax_included" => true })).to eq(1760)
      end

      it "converts tax-exclusive prices to tax-included (10%)" do
        expect(call_with({ "price" => 1600, "tax_included" => false })).to eq(1760)
      end

      it "returns the price as-is when the tax type is unknown" do
        expect(call_with({ "price" => 1980, "tax_included" => nil })).to eq(1980)
      end

      it "returns nil when no price was found" do
        expect(call_with({ "price" => nil, "tax_included" => nil })).to be_nil
      end

      it "returns nil for out-of-range values" do
        expect(call_with({ "price" => 5, "tax_included" => true })).to be_nil
        expect(call_with({ "price" => 9_999_999, "tax_included" => true })).to be_nil
      end

      it "returns nil when the API call raises" do
        reader = described_class.new("dummy")
        allow(reader).to receive(:extract_fields).and_raise(Timeout::Error)
        expect(reader.call).to be_nil
      end
    end
  end
end
