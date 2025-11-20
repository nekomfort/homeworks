#!/usr/bin/env python
# coding: utf-8

# In[12]:


import os
import pandas as pd


def generate_input_data(input_dir: str):
    os.makedirs(input_dir, exist_ok=True)

    sample_metadata = pd.DataFrame({
        'sample_id': ['Sample_1', 'Sample_2', 'Sample_3', 'Sample_4', 'Sample_5', 'Sample_6', 'Sample_7', 'Sample_8'],
        'cell_type': ['HEK293', 'HeLa', 'HEK293', 'U2OS', 'HeLa', 'Primary', 'U2OS', 'HeLa'],
        'treatment': ['Control', 'Drug_A', 'Drug_B', 'Control', 'Drug_A', 'Drug_C', 'Drug_B', 'Control'],
        'replicate': [1, 1, 1, 2, 2, 1, 2, 1],
        'concentration_uM': [0, 10, 50, 0, 10, 100, 10, 0]
    })

    mass_spec_results = pd.DataFrame({
        'sample_id': ['Sample_1', 'Sample_2', 'Sample_3', 'Sample_4', 'Sample_7'],
        'total_proteins': [2450, 2310, 2540, 2480, 2600],
        'unique_peptides': [15200, 14800, 15600, 15400, 16200],
        'contamination_level': [0.02, 0.05, 0.03, 0.01, 0.04]
    })

    quality_metrics = pd.DataFrame({
        'sample_id': ['Sample_2', 'Sample_3', 'Sample_4', 'Sample_5', 'Sample_8'],
        'rin_score': [8.5, 7.2, 9.1, 6.8, 8.9],
        'pcr_duplication': [0.12, 0.18, 0.09, 0.25, 0.11],
        'mapping_rate': [0.95, 0.87, 0.96, 0.82, 0.94]
    })

    sample_path = os.path.join(input_dir, "sample_metadata.csv")
    ms_path = os.path.join(input_dir, "mass_spec_results.csv")
    quality_path = os.path.join(input_dir, "quality_metrics.csv")

    sample_metadata.to_csv(sample_path, index=False)
    mass_spec_results.to_csv(ms_path, index=False)
    quality_metrics.to_csv(quality_path, index=False)

    print("Входные файлы сгенерированы и сохранены в:", input_dir)
    print(" -", sample_path)
    print(" -", ms_path)
    print(" -", quality_path)

def read_input_tables(input_dir: str):
    paths = {
        "sample_metadata": os.path.join(input_dir, "sample_metadata.csv"),
        "mass_spec_results": os.path.join(input_dir, "mass_spec_results.csv"),
        "quality_metrics": os.path.join(input_dir, "quality_metrics.csv"),
    }

    print(f"Читаем входные таблицы из {input_dir}")
    sample_metadata = pd.read_csv(paths["sample_metadata"])
    mass_spec_results = pd.read_csv(paths["mass_spec_results"])
    quality_metrics = pd.read_csv(paths["quality_metrics"])

    print(f"sample_metadata: {sample_metadata.shape[0]} строк, {sample_metadata.shape[1]} столбцов")
    print(f"mass_spec_results: {mass_spec_results.shape[0]} строк, {mass_spec_results.shape[1]} столбцов")
    print(f"quality_metrics: {quality_metrics.shape[0]} строк, {quality_metrics.shape[1]} столбцов")

    return sample_metadata, mass_spec_results, quality_metrics

def perform_joins(sample_metadata, mass_spec_results, quality_metrics, output_dir: str):
    os.makedirs(output_dir, exist_ok=True)

    join_types = ["inner", "left", "right", "outer"]

    for how in join_types:
        print("=" * 80)
        print(f"Выполняем {how.upper()} join для трёх таблиц")

        # 1) metadata + mass spec
        join1 = pd.merge(
            quality_metrics,
            mass_spec_results,
            on="sample_id",
            how=how,
            suffixes=("_meta", "_ms"),
        )

        print(
            f"После {how.upper()} join (qual x ms): "
            f"{join1.shape[0]} строк, {join1.shape[1]} столбцов"
        )

        # 2) + metadata
        result = pd.merge(
            join1,
            sample_metadata,
            on="sample_id",
            how='inner',
        )

        total_rows, total_cols = result.shape
        na_counts = result.isna().sum()

        print(
            f"Итоговая таблица ({how.upper()} join для 3 таблиц): "
            f"{total_rows} строк, {total_cols} столбцов"
        )
        print("Количество пропусков по столбцам (top 10):")
        print(na_counts.sort_values(ascending=False).head(10))

        out_path = os.path.join(output_dir, f"join_{how}.csv")
        result.to_csv(out_path, index=False)
        print(f"Результат {how.upper()} join сохранён в {out_path}")


def main():
    input_dir = os.getenv("INPUT_DIR", "input")
    output_dir = os.getenv("OUTPUT_DIR", "output")

    print("INPUT_DIR =", input_dir)
    print("OUTPUT_DIR =", output_dir)

    generate_input_data(input_dir)

    sample_metadata, mass_spec_results, quality_metrics = read_input_tables(input_dir)

    perform_joins(sample_metadata, mass_spec_results, quality_metrics, output_dir)

    print("Все джоины успешно выполнены.")


if __name__ == "__main__":
    main()

