# Джойны таблиц в pandas (Docker)

Скрипт `join.py` внутри контейнера:
- генерирует входные CSV-файлы в `/data/input`
- выполняет все типы объединений (INNER, LEFT, RIGHT, OUTER)
- сохраняет результаты в смонтированную папку `/data/output` в виде `join_inner.csv`, `join_left.csv`, `join_right.csv`, `join_outer.csv`

Важно, что контейнер предполагает объединение данных всех типов для "Результаты масс-спектрометрии" и "Данные о качестве". Объединение с метаданными всегда происходит по INNER, так как метаданные сгенерированы для всех образцов.

## сборка

```bash
docker build -t joins .

## запуск

mkdir -p input output
chmod 777 output

docker run --rm \
  -v "$(pwd)/input:/data/input" \
  -v "$(pwd)/output:/data/output" \
  joins

После выполнения контейнера:
во входной папке ./input появятся сгенерированные CSV:
sample_metadata.csv
mass_spec_results.csv
quality_metrics.csv

в папке ./output появятся результаты джойнов:
join_inner.csv
join_left.csv
join_right.csv
join_outer.csv