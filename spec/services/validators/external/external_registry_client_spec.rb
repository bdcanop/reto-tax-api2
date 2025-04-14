require 'rails_helper'

RSpec.describe Validators::External::ExternalRegistryClient do
  let(:base_url) { 'http://localhost:4567/api/validate' }

  it 'returns business data for an active record' do
    stub_request(:get, base_url)
      .with(query: { number: "GB123456786" })
      .to_return(
        status: 200,
        body: { active: true, name: "Fake Co", address: "123 London Rd" }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    result = described_class.lookup("GB123456786")
    expect(result[:success]).to be true
    expect(result[:active]).to be true
    expect(result[:name]).to eq("Fake Co")
  end

  it 'returns inactive status properly' do
    stub_request(:get, base_url)
      .with(query: { number: "DE123456789" })
      .to_return(
        status: 200,
        body: { active: false }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    result = described_class.lookup("DE123456789")
    expect(result[:success]).to be true
    expect(result[:active]).to be false
  end

  it 'handles not found (404)' do
    stub_request(:get, base_url)
      .with(query: { number: "NOTFOUND" })
      .to_return(status: 404)

    result = described_class.lookup("NOTFOUND")
    expect(result[:success]).to be false
    expect(result[:error]).to eq("Number not found in registry")
  end

  it 'handles server error (500)' do
    stub_request(:get, base_url)
      .with(query: { number: "error500" })
      .to_return(status: 500)

    result = described_class.lookup("error500")
    expect(result[:success]).to be false
    expect(result[:error]).to eq("Could not reach the external VAT registry")
  end
end
