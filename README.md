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

- Análisis de hojas y columnas: [`docs/DATOS.md`](docs/DATOS.md)  
- Plan y decisiones pendientes: [`docs/PLAN.md`](docs/PLAN.md)  
- Alcance confirmado con Ruy: [`docs/RESPUESTAS_RUY.md`](docs/RESPUESTAS_RUY.md)  

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

Detalle de reglas y decisiones: [`docs/DECISIONES.md`](docs/DECISIONES.md).

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
