# Inequality as the Missing Link in the Climate-Migration Nexus

Replication code for a global, descriptive analysis of how climate change and migration are jointly structured by global inequality.

**Author:** Jisung Park

## Overview

Most work linking climate, migration, and inequality treats the relationship as unidirectional (climate change → inequality → migration) and relies on single-country case studies. This project takes an explicitly global approach and inverts that framing, placing climate change and migration *within* patterns of unequal development and unequal vulnerability that are historically rooted in colonialism and extractive capitalism.

Two descriptive relationships anchor the argument:

- **Unequal development** — the largest cumulative CO2 emitters are also the largest recipients of migrants.
- **Unequal vulnerabilities** — the countries most exposed to climate-related humanitarian risk have the weakest rights to movement.

<img width="1077" height="659" alt="Conceptual_Framework" src="https://github.com/user-attachments/assets/8f95c60b-5b7b-4d52-928d-cfcdc4d40920" />


## Repository structure

```
CCMRI.R                          # Full analysis: cleaning, merging, plots, correlations
data/
  migration_co2.csv              # Migrant stock, cumulative CO2, INFORM indicators
  henley20_26.csv                # Henley Passport Index, 2020-2026
  unhcr/persons_of_concern.csv   # UNHCR persons of concern
output/
  figure1.png                    # Saved figures
```

GDP and GDP per capita are pulled directly from Our World in Data at runtime, so an internet connection is required.

## Data sources

| Variable | Source |
| --- | --- |
| Migrant stock, cumulative CO2 emissions | Compiled from multiple sources (`migration_co2.csv`) |
| GDP, GDP per capita | Our World in Data (World Bank) |
| Refugees, asylum seekers, IDPs, stateless persons | UNHCR |
| Visa-free access (`Henley_avg`) | Henley Passport Index, averaged over 2020-2026 |
| Climate-related humanitarian risk (`INFORM_O50`) | INFORM Climate Change Index, 2050 "optimistic" scenario |

## Requirements

R with `dplyr`, `ggplot2`, `corrplot`, `countrycode`, and `ggrepel`.

```r
install.packages(c("dplyr", "ggplot2", "corrplot", "countrycode", "ggrepel"))
```

## Usage

Run `CCMRI.R` from the project root. The script proceeds in three sections:

0. **Data cleaning** — loads and harmonises the five sources, merges them on ISO country code into a single `climig` data frame, and derives `Henley_avg`, `FDPs`, and standardised World Bank regions.
1. **Plots** — country-level and region-averaged scatterplots. `Figure1` (CO2 vs. migrant stock) and `Figure2` (humanitarian risk vs. visa-free access) are the two figures used in the presentation.
2. **Correlations** — Pearson and Spearman correlation matrices across all numeric indicators.
3. **Regressions** An optional third section fits simple bivariate OLS models.

## Limitations

Analysis is at the national level, which masks intersectional patterns of inequality within countries along lines of race, gender, and class. The relationships reported are descriptive and correlational, not causal.
