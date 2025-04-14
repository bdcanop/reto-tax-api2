# spec/services/validators/pipeline_validator_spec.rb
require 'rails_helper'

RSpec.describe Validators::PipelineValidator do
  let(:base_url) { 'http://localhost:4567/api/validate' }

  before do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  context 'with valid GB VAT number and active external response' do
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

    it 'validates successfully with business data' do
      validator = described_class.new("GB", number).run

      expect(validator.valid?).to be true
      expect(validator.formatted_tax_number).to eq("GB 123 4567 86")
      expect(validator.business_data[:name]).to eq("Test LTD")
      expect(validator.errors).to be_empty
    end
  end

  context 'with valid DE VAT number but inactive externally' do
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

    it 'fails due to external registry being inactive' do
      validator = described_class.new("DE", number).run

      expect(validator.valid?).to be false
      expect(validator.formatted_tax_number).to eq("DE 123456788")
      expect(validator.errors).to include("Number not active in registry")
    end
  end

  context 'with checksum failure in GB VAT' do
    let(:number) { 'GB123456780' }

    it 'fails checksum validation and skips external' do
      validator = described_class.new("GB", number).run

      expect(validator.valid?).to be false
      expect(validator.errors.any? { |e| e.include?("Checksum validation failed") }).to be true
    end
  end

  context 'with unsupported country' do
    let(:number) { 'ZZ999999999' }

    it 'fails with unsupported country error' do
      validator = described_class.new("ZZ", number).run

      expect(validator.valid?).to be false
      expect(validator.errors).to include("Unsupported country code")
    end
  end
end
