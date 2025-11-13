# Анализ гемоглобина (Docker)

Скрипт читает `./common/Пациенты.xlsx` и сохраняет `анализ_гемоглобина.csv` в смонтированную папку `/output`

## сборка
docker build -t hemoglobin-analytics .

## запуск 

mkdir -p common output

## необходимо загрузить Excel: ./common/Пациенты.xlsx
docker run --rm \
  -v "$(pwd)/common:/app/common:ro" \
  -v "$(pwd)/output:/output" \
  hemoglobin-analytics

## необходимо предварительно загрузить Excel: ./common/Пациенты.xlsx