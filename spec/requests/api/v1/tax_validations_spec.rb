# spec/integration/tax_validations_spec.rb
require 'swagger_helper'

RSpec.describe 'Tax Validations API', type: :request do
  path '/api/v1/tax_validations/validate' do
    post 'Validates a tax registration number' do
      tags 'Tax Validations'

      description(<<~DESC)
        Realiza la validación completa de un número fiscal, aplicando validaciones de formato, checksum y verificación externa.
        Dependiendo del `tax_number` enviado, la respuesta varía:
        - Si falla el formato: se devuelve valid: false y se incluye la explicación del error de formato.
        - Si pasa el formato pero falla el checksum: se devuelve valid: false y se indica el error del checksum.
        - Si pasa formato y checksum, pero la validación externa falla (por ejemplo, el número no está activo o no se encontró): se devuelve valid: false junto al mensaje de error.
        - Si todo es correcto, se devuelve valid: true junto con el número formateado y, opcionalmente, la información de la empresa.
      DESC

      consumes 'application/json'
      produces 'application/json'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          country_code: { type: :string, example: 'GB', description: 'Código ISO del país: US, GB o DE' },
          tax_number: { type: :string, example: '123456786', description: 'Número fiscal sin formato (se normaliza en la respuesta)' }
        },
        required: %w[country_code tax_number]
      }

      response '200', 'Response scenarios' do
        # Agregamos un let por defecto para evitar el error de "Missing parameter 'payload'"
        let(:payload) { { country_code: 'GB', tax_number: '123456786' } }

        # Definimos el esquema general de la respuesta
        schema type: :object,
               properties: {
                 valid: { type: :boolean, example: true },
                 tax_type: { type: :string, example: 'gb_vat' },
                 formatted_tax_number: { type: :string, example: 'GB 123 4567 86' },
                 errors: { type: :array, items: { type: :string } },
                 business_registration: {
                   type: :object,
                   properties: {
                     name: { type: :string, example: 'Test LTD' },
                     address: { type: :string, example: '1 Test St' }
                   },
                   nullable: true
                 },
                 external_service_message: { type: :string, nullable: true }
               },
               required: %w[valid tax_type formatted_tax_number errors]

        # Ejemplo cuando la validación es exitosa:
        example 'application/json', 'Valid tax number', {
          valid: true,
          tax_type: 'gb_vat',
          formatted_tax_number: 'GB 123 4567 86',
          errors: [],
          business_registration: { name: 'Test LTD', address: '1 Test St' },
          external_service_message: nil
        }

        # Ejemplo de fallo por formato incorrecto
        example 'application/json', 'Format validation failure', {
          valid: false,
          tax_type: 'gb_vat',
          formatted_tax_number: 'GB 123 4567 6',
          errors: [
            "Invalid characters detected: VAT number must contain only numeric digits",
            "Incorrect length: expected 9 digits but found 8"
          ],
          business_registration: nil,
          external_service_message: nil
        }

        # Ejemplo de fallo por checksum inválido
        example 'application/json', 'Checksum validation failure', {
          valid: false,
          tax_type: 'gb_vat',
          formatted_tax_number: 'GB 123 4567 86',
          errors: [ "Checksum validation failed: expected check digit 6 but found 0" ],
          business_registration: nil,
          external_service_message: nil
        }

        # Ejemplo de fallo por validación externa (número inactivo)
        example 'application/json', 'External validation failure', {
          valid: false,
          tax_type: 'gb_vat',
          formatted_tax_number: 'GB 123 4567 86',
          errors: [ "Number not active in registry" ],
          business_registration: nil,
          external_service_message: "Number not active in registry"
        }

        example 'application/json', 'Unable to connect with external service', {
          valid: false,
          tax_type: 'gb_vat',
          formatted_tax_number: 'GB 123 4567 86',
          errors: [ "Unhandled error: Circuitbox::ServiceFailureError: Service" ],
          business_registration: nil,
          external_service_message: nil
        }

        run_test!
      end
    end
  end
end
