# Prueba técnica — catalogación de refacciones (Rails)

Aplicación Ruby on Rails que toma el Excel de **origen** y produce un Excel **equivalente al ejemplo** (cuatro hojas catalogadas).

## Contexto

Invitación de evaluación técnica: el foco no es solo el archivo final, sino **cómo se llegó** (decisiones, enfoque, estrategias).

**Entregables esperados**

1. Excel generado con datos catalogados  
2. Acceso al repositorio con la implementación  

## Datos de referencia (en el repo)

| Archivo | Uso |
|---------|-----|
| [`data/samples/prueba_tecnica.xlsx`](data/samples/prueba_tecnica.xlsx) | Entrada que debe procesar la app |
| [`data/samples/prueba_tecnica_ejemplo.xlsx`](data/samples/prueba_tecnica_ejemplo.xlsx) | Formato y contenido objetivo (referencia) |

Documentación del análisis de hojas y columnas: [`docs/DATOS.md`](docs/DATOS.md).

Plan de trabajo y decisiones pendientes: [`docs/PLAN.md`](docs/PLAN.md).

## Estado del repositorio

- [x] Repo inicial, muestras y documentación  
- [ ] Scaffold Rails  
- [ ] Lógica de transformación / enriquecimiento  
- [ ] Generación de Excel de salida  
- [ ] README de setup y uso para el evaluador  

## Requisitos previstos

- Ruby **3.0.2** (`.ruby-version`)  
- Rails (versión por definir al generar la app)  

## Próximo paso

Confirmar respuestas en [`docs/PLAN.md`](docs/PLAN.md) (preguntas abiertas) y ejecutar `rails new` con el stack acordado.
