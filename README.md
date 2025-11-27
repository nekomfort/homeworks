# Анти-джойны таблиц в dplyr (Docker)

Скрипт `join.R` внутри контейнера:

- проверяет, что установлен пакет **dplyr**, и выводит его версию;
- читает входные CSV-файлы из смонтированной папки `/app/data`:
  - `sample_metadata.csv`
  - `mass_spec_results.csv`
- выполняет три вида анти-объединений по полю `sample_id`:
  - **anti left** — строки из `sample_metadata`, которых нет в `mass_spec_results`;
  - **anti right** — строки из `mass_spec_results`, которых нет в `sample_metadata`;
  - **anti outer** — объединение результатов anti left и anti right с добавлением признака источника;
- сохраняет результаты в ту же смонтированную папку `/app/data` в виде:
  - `anti_left.csv`
  - `anti_right.csv`
  - `anti_outer.csv`

## Сборка

```bash
docker build -t anti-joins .

## Запуск

```bash
docker run --rm \
  -v "$(pwd)/data:/app/data" \
  anti-joins