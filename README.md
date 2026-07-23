# Prueba técnica — catalogación de refacciones (Rails)

Aplicación **Ruby on Rails 7.0** que toma el Excel de **origen** y produce un Excel **equivalente al ejemplo** (cuatro hojas catalogadas).

## Contexto

Invitación de evaluación técnica: el foco no es solo el archivo final, sino **cómo se llegó** (decisiones, enfoque, estrategias).

**Entregables esperados**

1. Excel generado con datos catalogados  
2. Acceso al repositorio con la implementación  

## Datos de referencia

| Archivo | Uso |
|---------|-----|
| [`data/samples/prueba_tecnica.xlsx`](data/samples/prueba_tecnica.xlsx) | Entrada que debe procesar la app |
| [`data/samples/prueba_tecnica_ejemplo.xlsx`](data/samples/prueba_tecnica_ejemplo.xlsx) | Formato y contenido objetivo (referencia) |

## Requisitos

- Ruby **3.0.2** (ver `.ruby-version`)  
- Bundler  
- SQLite3 (incluido vía gem `sqlite3`)  

## Setup

```bash
git clone <repo-url>
cd bonaparte-test
bin/setup
```

`bin/setup` ejecuta `bundle install`, prepara la base SQLite y limpia temporales.

## Desarrollo

```bash
bin/rails server
```

Abre [http://localhost:3000](http://localhost:3000).

## Uso

1. Inicia el servidor (`bin/rails server`).
2. En la página principal, sube [`data/samples/prueba_tecnica.xlsx`](data/samples/prueba_tecnica.xlsx).
3. Descarga `catalogo_generado.xlsx` con las hojas `Origen`, `Aplicaciones`, `Intercambios` y `Catálogo`.

## Tests

```bash
bin/rails test
```

## Estado del proyecto

- [x] Repo inicial, muestras y documentación  
- [x] Scaffold Rails 7.0 (SQLite, importmap, sin Action Cable/Mailer/Storage/Mailbox)  
- [x] Lógica de transformación / enriquecimiento (5 registros, heurística local)  
- [x] Generación de Excel de salida (roo + caxlsx)  
- [x] Flujo web upload/descarga documentado  

## Stack actual

| Componente | Elección |
|------------|----------|
| Rails | 7.0.10 |
| DB | SQLite (`db/development.sqlite3`) |
| JS | importmap-rails (sin Hotwire/Turbo por ahora) |
| Servidor | Puma |
| Excel | roo (lectura), caxlsx (escritura) |

Salidas Excel generadas (cuando existan): carpeta `output/` (archivos `.xlsx` ignorados por git).

## `ExcelCatalogGenerator` (mock, en paralelo)

El upload web sigue usando `Catalog::GenerateFromUpload`. Para generar un catálogo de **tres hojas** enriquecido con [`AutopartsMockService`](app/services/autoparts_mock_service.rb), usa [`ExcelCatalogGenerator`](app/services/excel_catalog_generator.rb):

```ruby
generator = ExcelCatalogGenerator.new("/ruta/al/prueba_tecnica.xlsx")
generator.call # => ruta tmp del .xlsx
# o
generator.to_stream # => bytes para send_data
```

### Conmutar el controlador (cuando quieras reemplazar el pipeline actual)

Sustituye el cuerpo de `CatalogController#create` por algo equivalente a:

```ruby
def create
  file = params[:file]
  validation = Catalog::UploadValidator.call(upload: file)
  unless validation[:ok]
    redirect_to root_path, alert: validation[:alert] and return
  end

  input_path = Rails.root.join("tmp", "catalog_input_#{SecureRandom.hex(8)}.xlsx").to_s
  File.binwrite(input_path, file.read)

  xlsx_bytes = ExcelCatalogGenerator.new(input_path).to_stream

  send_data(
    xlsx_bytes,
    filename: "catalogo_generado.xlsx",
    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    disposition: "attachment"
  )
rescue StandardError => e
  Rails.logger.error("Excel catalog generation failed: #{e.message}")
  redirect_to root_path, alert: "No se pudo generar el catálogo."
ensure
  File.delete(input_path) if defined?(input_path) && input_path && File.exist?(input_path)
end
```
