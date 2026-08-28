################################################################
# Title: Climate Change, Migration, and the Reproduction of Inequality
# Made by: Jisung Park
# Created: 9 April 2026
################################################################

## 0. DATA CLEANING

# Load libraries
# library(jsonlite)
library(dplyr)
library(ggplot2)
library(corrplot)
library(countrycode)
library(ggrepel)

# Load data
mig_co2 <- read.csv('data/migration_co2.csv')  # Made by myself aggregating data from different sources as some used excel
gdp_capita <- read.csv('https://ourworldindata.org/grapher/gdp-per-capita-worldbank.csv?v=1&csvType=filtered&useColumnShortNames=true')
gdp <- read.csv('https://ourworldindata.org/grapher/gdp-worldbank-constant-usd.csv?v=1&csvType=filtered&useColumnShortNames=true')
unhcr <- read.csv('data/persons_of_concern.csv')  # From UNHCR
henley <- read.csv('data/henley20_26.csv', check.names = FALSE)  # From Henley Passport Index, compiled using Claude

# Rename & remove columns (gdp_capita)
gdp_capita <- gdp_capita %>% 
  rename(
    Country = entity,
    Code = code,
    GDP_capita = ny_gdp_pcap_pp_kd,
    Region = owid_region
    ) |>
  select(
    -year,
    -ny_gdp_pcap_pp_kd__original_year
    )

# Rename & remove columns (gdp)
gdp <- gdp %>% 
  rename(
    Country = entity,
    Code = code,
    GDP = ny_gdp_mktp_kd,
    ) |>
  select(
    -year,
    -ny_gdp_mktp_kd__original_year
    )

# Rename & remove columns (unhcr)
unhcr <- unhcr %>%
  rename(
    Code = Country.of.Asylum.ISO,
    Asylum_seekers = Asylum.seekers,
    Others_protection = Other.people.in.need.of.international.protection,
    Stateless = Stateless.persons,
    Others_concern = Others.of.concern,
    ) |>
  select(
    -Year,
    -Country.of.Asylum,
    -Country.of.Origin,
    -Country.of.Origin.ISO,
    -Host.community
    )

# Remove columns (Henley)
henley <- henley %>% select(-Country)

# Change column name (mig_co2)
names(mig_co2)[1] <- 'Country'

# Merge data
climig <- mig_co2 |>
  left_join(gdp, by = c('Country', 'Code')) |>
  left_join(gdp_capita, by = c('Country', 'Code')) |>
  left_join(unhcr, by = 'Code') |>
  left_join(henley, by = 'Code')

# Drop columns that will not be used
## climig <- climig %>% select(-GCPRI, -Henley_index)

# Add average Henley column
climig$Henley_avg <- rowMeans(climig[, c('2020', '2021', '2022', '2023', '2024', '2025', '2026')])

# Add total forcibly displaced people
climig$FDPs <-  rowMeans(climig[, c('Refugees', 'Asylum_seekers', 'IDPs', 'Stateless', 'Others_protection', 'Others_concern')])

# Add missing regions & synchronise naming
climig$Region <- countrycode(climig$Country, 
                             origin = 'country.name', 
                             destination = 'region')

# Reorder columns
climig <- climig %>%
  relocate(Region, GDP_capita, GDP, .before = CO2_cumulative) %>%
  relocate(Henley_avg, .before = '2020') %>%
  relocate(FDPs, .before = Refugees)

# Check data
head(climig)
summary(climig)

################################################################

## I. PLOTS

# All by all
pairs(climig[4:19])

# Plot 1.1: Cumulative CO2 (log) vs Migrant stock (log)
ggplot(data = climig |> filter(!is.na(Region)),
       aes(x = log(CO2_cumulative), y = log(Migrant_stock))) +
  geom_point(aes(colour = Region)) +
  geom_smooth(method = 'lm', se = FALSE, colour = 'red')

# Plot 1.1.1: Using text labels
Figure1 <- ggplot(data = climig |> filter(!is.na(Region)),
                   aes(x = log(CO2_cumulative), y = log(Migrant_stock), label = Country)) +
  labs(y = 'Number of Migrants (log)', x = 'Cumulative CO2 Emission (log)') +
  geom_label(aes(fill = Region), colour = "white", fontface = "bold") +
  geom_smooth(method = 'lm', se = FALSE, colour = 'black')

# Plot 1.2: Cumulative CO2 (log) vs Refugees (log)
ggplot(data = climig |> filter(!is.na(Region)),
       aes(x = log(CO2_cumulative), y = log(Refugees))) +
  geom_point(aes(colour = Region)) +
  geom_smooth(method = 'lm', se = FALSE, colour = 'red')

# Plot 1.3: Cumulative CO2 (log) vs FDPs (log)
ggplot(data = climig |> filter(!is.na(Region)),
       aes(x = log(CO2_cumulative), y = log(FDPs))) +
  geom_point(aes(colour = Region)) +
  geom_smooth(method = 'lm', se = FALSE, colour = 'red')

# Plot 2.1: INFORM vs Henley
ggplot(data = climig |> filter(!is.na(Region)),
       aes(x = INFORM, y = Henley_avg)) +
  geom_point(aes(colour = Region)) +
  geom_smooth(method = 'lm', se = FALSE, colour = 'red')

# Plot 2.1.1: Using text labels
Figure2 <- ggplot(data = climig |> filter(!is.na(Region)),
                  aes(x = INFORM_O50, y = Henley_avg, label = Country)) +
  labs(y = 'Number of Visa Free Access', x = 'Risk of Humanitarian Crises') +
  geom_label(aes(fill = Region), colour = "white", fontface = "bold") +
  geom_smooth(method = 'lm', se = FALSE, colour = 'black')

# Plot 2.2: INFORM vs FDPs (log)
ggplot(data = climig |> filter(!is.na(Region)),
       aes(x = INFORM, y = log(FDPs))) +
  geom_point(aes(colour = Region)) +
  geom_smooth(method = 'lm', se = FALSE, colour = 'red')

# By region
regional_avg <- climig |>
  filter(!is.na(Region)) |>
  group_by(Region) |>
  summarise(
    CO2_cumulative = mean(CO2_cumulative, na.rm = TRUE),
    Migrant_stock  = mean(Migrant_stock,  na.rm = TRUE),
    Refugees  = mean(Refugees,  na.rm = TRUE),
    FDPs  = mean(FDPs,  na.rm = TRUE),
    INFORM = mean(INFORM,  na.rm = TRUE),
    Henley_avg = mean(Henley_avg, na.rm = TRUE)
  )

# Plot 3.1: Cumulative CO2 (log) vs Migrant stock (log) by region
ggplot(regional_avg, aes(x = log(CO2_cumulative), y = log(Migrant_stock))) +
  geom_point(aes(colour = Region), size = 4) +
  geom_smooth(method = 'lm', se = FALSE, colour = 'red')

# Plot 3.2: Cumulative CO2 (log) vs Refugees (log) by region
ggplot(regional_avg, aes(x = log(CO2_cumulative), y = log(Refugees))) +
  geom_point(aes(colour = Region), size = 4) +
  geom_smooth(method = 'lm', se = FALSE, colour = 'red')

# Plot 3.3: Cumulative CO2 (log) vs FDPs (log) by region
ggplot(regional_avg, aes(x = log(CO2_cumulative), y = log(FDPs))) +
  geom_point(aes(colour = Region), size = 4) +
  geom_smooth(method = 'lm', se = FALSE, colour = 'red')

# Plot 3.4: INFORM vs Henley by region
ggplot(regional_avg, aes(x = INFORM, y = Henley_avg)) +
  geom_point(aes(colour = Region), size = 4) +
  geom_smooth(method = 'lm', se = FALSE, colour = 'red')

# ggsave('output/figure1.png', plot = Figure1, width = 15, height = 8, dpi = 300)

################################################################

## II. CORRELATIONS

# All variables (Pearson)
corrplot(cor(climig[4:19], use = 'complete'),
         method = 'color',
         type = 'upper',
         diag = FALSE,
         order = 'FPC',
         addCoef.col = 'black',
         )

# All variables
corrplot(cor(climig[4:19], use = 'complete'),
         method = 'color',
         type = 'upper'
         )

# All variables (Spearman)
corrplot(cor(climig[4:19], use = 'pairwise', method = 'spearman'),
         method = 'color',
         type = 'upper'
         )

################################################################

III. REGRESSION MODELS (OPTIONAL)

# summary(lm(INFORM ~ CO2_capita_2024, climig))
# summary(lm(Migrant_stock ~ CO2_cumulative, climig))