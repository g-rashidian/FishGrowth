
# FishGrowth

**FishGrowth** is an R package designed to automate the analysis of
growth performance in fish dietary experiments. It streamlines the
workflow from data import to journal-ready reporting.

## Installation

You can install and load the latest version from
[GitHub](https://github.com/) with:

``` r

# install.packages("devtools")
devtools::install_github("YourGitHubUsername/FishGrowth")
#load the package
library(FishGrowth)
```

## Quick Start Guide

The typical workflow involves the following steps:

# 1. Generate or Import Data

# We can use built-in simulation data for practice

df \<- create_simulation_data(n_reps = 3) \#Simulate 3 replicates per
treatment \# View the first few rows of the data head(df)

\#Custom parameters example for advanced users including 5 replicates,

\#60 fish per tank, over 12 weeks (84 days)

`df <- create_simulation_data(n_reps = 5, n_fish_per_tank = 60, days = 84)  # View the first few rows of the data head(df)`
\# 2. Process & Metrics Calculation \# Calculate growth metrics from df
(data frame) over 84 days df_calc \<- calculate_metrics(df, days = 84)

# View the first few rows of the calculated data

head(df_calc)

# 3. Aggregate (Tank Level) - CRITICAL for Stats

    # Aggregate individual fish data to tank-level averages

\#this step is essential for proper statistical analysis

df_tank \<- aggregate_tank_data(df_calc)

# 4. Visualize Results - Treatment Comparisons

# Plotting function to compare treatments for a given parameter

# Plot Final Weight Comparison Across Treatments

plot_treatment_comparison(df_tank, “mean_weight_final”, “Final Weight
(g)”)

# Plot Specific Growth Rate (SGR) Comparison Across Treatments

plot_treatment_comparison(df_tank, “mean_sgr”, “Specific Growth Rate
(%/day)”)

# 5. Generate Final Table

# Generate a summary table for key parameters of your choice

params \<- c(“mean_weight_final”, “mean_sgr”, “fcr”)
generate_summary_table(df_tank, params)

    #generate summary table for all parameters
    generate_summary_table(df_tank)

# 6. Save Full Project Results

# Export all results to a timestamped folder for record-keeping

save_project_results(df_calc, df_tank, params)
