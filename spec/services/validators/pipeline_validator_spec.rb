require 'rails_helper'

RSpec.describe Validators::PipelineValidator do
  let(:base_url) { 'http://localhost:4567/api/validate' }

  before do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  context 'when GB VAT is valid and registry is active' do
    let(:number) { 'GB 123 4567 86' }

    before do
      stub_request(:get, base_url)
        .with(query: { number: number })
        .to_return(
          status: 200,
          body: { active: true, name: 'Test LTD', address: '1 Test St' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'passes all validations' do
      validator = described_class.new("GB", number).run

      expect(validator.valid?).to be true
      expect(validator.formatted_tax_number).to eq("GB 123 4567 86")
      expect(validator.errors).to be_empty
    end
  end

  context 'when checksum is invalid for GB VAT' do
    let(:number) { 'GB123456780' }

    it 'fails with a checksum error' do
      validator = described_class.new("GB", number).run

      expect(validator.valid?).to be false
      expect(validator.errors.first).to include("Checksum validation failed")
    end
  end

  context 'when DE VAT is valid but inactive in registry' do
    let(:number) { 'DE 123456788' }

    before do
      stub_request(:get, base_url)
        .with(query: { number: number })
        .to_return(
          status: 200,
          body: { active: false }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns error for inactive number' do
      validator = described_class.new("DE", number).run

      expect(validator.valid?).to be false
      expect(validator.errors).to include("Number not active in registry")
      expect(validator.formatted_tax_number).to eq("DE 123456788")
    end
  end

  context 'when external service is unavailable (500)' do
    let(:number) { 'GB 123 4567 86' }

    before do
      stub_request(:get, base_url)
        .with(query: { number: number })
        .to_return(status: 500)
    end

    it 'returns an external service error' do
      validator = described_class.new("GB", number).run

      expect(validator.valid?).to be false
      expect(validator.errors).to include("Could not reach the external VAT registry")
    end
  end

  context 'when unsupported country is used' do
    it 'returns unsupported country error' do
      validator = described_class.new("FR", "123456789").run

      expect(validator.valid?).to be false
      expect(validator.errors).to include("Unsupported country code")
    end
  end
end
