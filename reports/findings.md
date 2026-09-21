# Healthy diet cost panel findings

## Question and sample

How do reported healthy-diet costs vary across the 12 countries selected in the original July 2026 progress report? The reproduced panel spans 2017–2024 and has one record per country-year. It contains 96 observations with no missing values in diet cost or the seven selected macroeconomic variables.

## Descriptive findings

In the supplied records, reported daily costs range from 2.12 to 6.38 PPP dollars, with an unweighted country-year mean of 3.717. Each selected country has a higher recorded cost in 2024 than in 2017. Percentage changes range from 29.67% in South Africa to 67.45% in Egypt. These values describe this specific supplied file and should not be cited as independently verified official estimates.

Full endpoint calculations are in `../results/endpoint_changes.csv`; descriptive statistics are in `../results/descriptive_statistics.csv`.

## Validation and limitations

The workflow checks country-year key uniqueness before merging, harmonizes Egypt's name, and confirms all selected food-cost observations match the macroeconomic table. Original region labels fail an explicit geographic check for 11 of 12 countries and are excluded. All 1,379 records in the full food-cost input carry an Estimated value label. These issues require checking the original source and release documentation before substantive policy conclusions.

The cost measure is not an affordability measure: household resources and a consistent expenditure concept are required to evaluate affordability. The analysis does not estimate the effect of inflation, trade, policy, or any other variable on diet costs. A higher endpoint alone does not identify the cause of the increase.

## Reproduction

Run `Rscript scripts/run_analysis.R` from the repository root after placing the two original CSV inputs in `data/`. The script writes the selected panel, summary statistics, endpoint changes, region audit, and trend figure. The summer project supplied the join and selected sample; validation and this report were added in September 2026.
