# Global Tax Registration Validation API

Una API para validar números de registro fiscal de diferentes jurisdicciones (US, GB, DE) a través de tres fases de validación (formato, checksum y verificación externa). La API está diseñada con un enfoque modular, tolerante a fallos y fácilmente extensible, utilizando herramientas y técnicas modernas como feature flags, custom errors, Circuit Breakers, documentación Swagger y tests automatizados.

---

## Características

- **Validación de Formato:**  
  - **US:** Valida el formato de EIN (9 dígitos, formateado como `NN-NNNNNNN`).
  - **GB:** Valida el VAT de Reino Unido (9 dígitos, se estandariza a `GB 123 4567 89`).
  - **DE:** Valida el VAT de Alemania (9 dígitos con prefijo, formateado como `DE 123456788`).

- **Validación de Checksum (Fase 2):**  
  - Para GB y DE se implementa una verificación algorítmica del dígito de control.

- **Validación Externa (Fase 3):**  
  - Simula la validación de un registro fiscal mediante un servicio externo (mock en Sinatra) que retorna información sobre la empresa (nombre y dirección) o error (por ejemplo, número inactivo).

- **Tolerancia a Fallos:**  
  - Uso de timeouts, reintentos y Circuit Breaker (Circuitbox + Faraday) en las peticiones al servicio externo, para evitar bloqueos y responder rápidamente en caso de caídas persistentes.

- **Feature Flags:**  
  - Control dinámico mediante Flipper para habilitar o deshabilitar la validación externa (`:use_external_validation`) y la validación de checksum (`:enable_checksum_validation`).

- **Manejo de Errores Personalizado:**  
  - Uso de excepciones y error objects (`ValidationErrors::*`) para informar con claridad el motivo del fallo (formato, checksum, servicio externo, país no soportado, etc.).

- **Documentación Swagger:**  
  - Documentación interactiva generada con **rswag** para que los consumidores de la API conozcan el contrato y puedan probar distintos escenarios de respuesta.

- **Pruebas Automatizadas:**  
  - Cobertura de tests con RSpec y SimpleCov que cubre las distintas fases del pipeline, integraciones y manejo de feature flags.

---

## Requisitos y Dependencias

- **Ruby:** Versión 3.0 o superior (recomendado).
- **Rails:** API-only Rails app (versión 7 o superior).
- **Bundler:** Para gestionar gemas.
- **Dependencias principales:**
  - `rswag` para documentación Swagger.
  - `flipper` y `flipper-ui` para feature flags.
  - `faraday` y `faraday-retry` para llamadas HTTP resilientes.
  - `circuitbox` para el pattern de Circuit Breaker.
  - `simplecov` para métricas de cobertura de tests.
  - Además de las gemas estándar para testing (`rspec-rails`, etc.).

---

## Instalación

1. Clona el repositorio:

    ```bash
    git clone https://github.com/bdcanop/reto-tax-api2.git
    ```
    
2. Dirígete a la carpeta del proyecto:

   ```bash
   cd reto-tax-api2
   ```
   
3. Instala las dependencias:

    ```bash
    bundle install
    ```

---

## Uso de la API

### Ejecutar el Servidor

Levanta la aplicación Rails de tipo API:

```bash
rails s
```

La API estará disponible por defecto en [http://localhost:3000](http://localhost:3000).

### Endpoint Principal

- **Endpoint:** `POST /api/v1/tax_validations/validate`
- **Payload JSON:**

    ```json
    {
      "country_code": "GB",
      "tax_number": "123456786"
    }
    ```

- **Respuesta Exitosa (ejemplo):**

    ```json
    {
      "valid": true,
      "tax_type": "gb_vat",
      "formatted_tax_number": "GB 123 4567 86",
      "errors": [],
      "business_registration": {
        "name": "Test LTD",
        "address": "1 Test St"
      },
      "external_service_message": null
    }
    ```

- **Casos de Error:**  
  Dependiendo de la entrada, la respuesta (status code 200) puede incluir `valid: false` y un listado en `errors` explicando el fallo (error de formato, checksum o validación externa).

---

## Ejecución de Pruebas

1. Para correr todas las pruebas con RSpec:

    ```bash
    bundle exec rspec
    ```

2. Para ver el informe de cobertura generado por SimpleCov, abre el archivo generado en la carpeta `coverage/`:

    ```bash
    open coverage/index.html
    ```
    
    (En Linux, usa `xdg-open coverage/index.html`).

---

## Documentación Interactiva (Swagger)

La documentación Swagger se genera y actualiza automáticamente a partir de los tests con **rswag**.

1. Genera la documentación:

    ```bash
    bundle exec rake rswag:specs:swaggerize
    ```

2. Accede a la interfaz Swagger UI en [http://localhost:3000/api-docs](http://localhost:3000/api-docs).  
   Aquí verás ejemplos para cada escenario: validación exitosa, fallo en formato, error en checksum y error de validación externa.

---

## Ejecución del Servicio Externo (Simulación)

La API depende de un servicio externo simulado (un mock) que valida el número fiscal. Este servicio se implementa como una aplicación Sinatra.

1. En una carpeta distinta a la del proyecto principal, clona el repositorio del mock:
  
   ```bash
   git clone https://github.com/bdcanop/mock_tax_registry.git
   ```
 
2. Diríjete a la carpeta del proyecto del mock:

    ```bash
    cd mock_tax_registry
    ```

3. Instala las dependencias del mock:

    ```bash
    bundle install
    ```

4. Ejecuta el servicio:

    ```bash
    ruby app.rb
    ```

Por defecto, este mock corre en [http://localhost:4567](http://localhost:4567).

---

## Uso de Feature Flags

Utiliza **Flipper** para activar/desactivar dinámicamente funcionalidades:

- **Validación externa:**  
  - Habilitar: `Flipper.enable(:use_external_validation)`
  - Deshabilitar: `Flipper.disable(:use_external_validation)`

- **Validación de checksum:**  
  - Habilitar: `Flipper.enable(:enable_checksum_validation)`
  - Deshabilitar: `Flipper.disable(:enable_checksum_validation)`

Puedes gestionar estos flags vía consola o, si configuras la UI, accediendo a [http://localhost:3000/flipper](http://localhost:3000/flipper).
