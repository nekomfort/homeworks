# Анти-джойны таблиц в snakemake

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

## 0. Загрузить join.R (обновленный), Dockerfile, Snakefile

## 1. Собрать образ
docker build -t anti-joins .

## 2. Экспортировать образ в tar (путь подобрать под себя)
docker save anti-joins:latest -o /home/ВАШ_ЛОГИН/anti-joins.tar

## 3. В Snakefile прописать:

CONTAINER_URI = "docker-archive:///home/ВАШ_ЛОГИН/anti-joins.tar"

## 4. Запустить пайплайн
snakemake output/anti_outer.csv --cores 1 --use-singularity -p

#Графы

snakemake --rulegraph | dot -Tpng > rulegraph.png
snakemake --filegraph | dot -Tpng > filegraph.png

### Граф правил

![Rule graph](http://158.160.31.139:8787/files/rulegraph.png)

### Граф файлов

![File graph](http://158.160.31.139:8787/files/filegraph.png)