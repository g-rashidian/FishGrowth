
# FishGrowth

**FishGrowth** is an R package designed to automate the analysis of
growth performance in fish dietary experiments. It streamlines the
workflow from data import to journal-ready reporting.

## Installation

You can install and load the latest version from GitHub with:

# install.packages(“devtools”)

devtools::install_github(“g-rashidian/FishGrowth”)

# Load the package

\#load the package

library(FishGrowth)

## 

Quick Start Guide The typical workflow involves the following steps:

before starting, download the data template to fill in your experimental
data:

# Step 0: Get Data Template

***Use the built-in function to download a blank CSV template for your
data. get_data_template(“my_fish_data.csv”) This file can be opened in
Excel or any text editor. Fill in your experimental data following the
provided format. Once completed, you can import it using the
`import_fish_data()` function.***

***The following steps assume you have either simulated data or imported
your own data using the template.***

1.  Generate or Import Data We can use built-in simulation data for
    practice.

# Simulate 3 replicates per treatment

df \<- create_simulation_data(n_reps = 3)

# View the first few rows of the data

head(df) For advanced users, you can customize parameters (e.g., 5
replicates, 60 fish, 84 days):

df \<- create_simulation_data(n_reps = 5, n_fish = 60) \# Note: function
argument is n_fish, not n_fish_per_tank head(df)

# data processing and calculation

2.  Process & Metrics Calculation Calculate growth metrics over the
    experiment duration.

# Calculate growth metrics from df (data frame) over 84 days

df_calc \<- calculate_metrics(df, days = 84)

# View the first few rows

head(df_calc)

# tank-level aggregation and statistical analysis

3.  Aggregate (Tank Level) - CRITICAL Aggregate individual fish data to
    tank-level averages. This step is essential for proper statistical
    analysis.

df_tank \<- aggregate_tank_data(df_calc)

# View the results for verification

4.  Visualize Results Compare treatments for specific parameters using
    the built-in plotting function.

# Plot Final Weight Comparison

plot_treatment_comparison(df_tank, “mean_weight_final”, “Final Weight
(g)”)

# Plot Specific Growth Rate (SGR) Comparison

plot_treatment_comparison(df_tank, “mean_sgr”, “Specific Growth Rate
(%/day)”)

# table results

5.  Generate Final Table Generate a summary table with Mean ± SE and
    significance letters.

# Define key parameters

params \<- c(“mean_weight_final”, “mean_sgr”, “fcr”)

# Generate table

generate_summary_table(df_tank, params)

# saving and exporting all results

6.  Save Full Project Results Export all results (CSVs, Stats, Tables)
    to a timestamped folder.

save_project_results(df_calc, df_tank, params)
