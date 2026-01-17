
# FishGrowth

**FishGrowth** is an R package designed to automate the analysis of
growth performance in fish dietary experiments. It streamlines the
workflow from data import to journal-ready reporting.

## Installation

You can install and load the latest version from GitHub with:

# install.packages(“devtools”)

devtools::install_github("g-rashidian/FishGrowth")

# Load the package

\#load the package

library(FishGrowth)

## 

Quick Start Guide ***To see the full guide at any time, run***
This shows the Step-by-Step Guide

**fishgrowth_guide()**

# If you type the package name followed by two colons, RStudio will show a pop-up list of all available tools.

Type this in your console (don’t press Enter yet): FishGrowth::

Then press TAB-\> You will see a dropdown list of all functions
available to you.
Alternatively, you can use the following to see the list of all functions:

**help(package = "FishGrowth")**
## 

The typical workflow involves the following steps:

Before starting, download the data template to fill in your experimental data:
To get a blank Excel file: Use

**get_data_template()**

Paste or transfer your data into this file and save it as CSV in your
desired working directory.

# Step 0: Get Data Template

***Use the built-in function to download a blank CSV template for your
data. get_data_template(“my_fish_data.csv”). This file can be opened in
Excel or any text editor. Fill in your experimental data following the
provided format. Once completed, you can import it using the
`import_fish_data()` function.***

You should set the working directory to the folder where you saved the
file using setwd(“path/to/your/folder”)

df \<- import_fish_data(‘my_study.csv’)

I recommend using absolute path to avoid confusion.

***The following steps assume you have either simulated data or imported
your own data using the template.***

# Step-by-Step Workflow

1.  Generate or Import Data. You can use built-in simulation data for
    practice.

To get practice data: Use df \<- create_simulation_data() the default is
15 fish per tank

# Simulate 3 replicates per treatment

df \<- create_simulation_data(n_reps = 3)

# View the first few rows of the data

head(df) For advanced users, you can customize parameters (e.g., 5
replicates, 60 fish, 84 days):

df \<- create_simulation_data(n_reps = 5, n_fish = 60) \# Note: function
argument is n_fish, not n_fish_per_tank head(df)

# data processing and calculation

2.  Process & Metrics Calculation: Calculate growth metrics over the
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

4.  Visualize Results: Compare treatments for specific parameters using
    the built-in plotting function.

# Plot Final Weight Comparison

plot_treatment_comparison(df_tank, “mean_weight_final”, “Final Weight
(g)”)

# Plot Specific Growth Rate (SGR) Comparison

plot_treatment_comparison(df_tank, “mean_sgr”, “Specific Growth Rate
(%/day)”)

# table results

5.  Generate Final Table: Generate a summary table with Mean ± SE and
    significance letters.

# Define key parameters

params \<- c(“mean_weight_final”, “mean_sgr”, “fcr”)

# Generate table

generate_summary_table(df_tank, params)

# saving and exporting all results

6.  Save Full Project Results: Export all results (CSVs, Stats, Tables)
    to a timestamped folder.

save_project_results(df_calc, df_tank, params) \# Results are saved in
“Results” folder by default in working directory. \# This creates a
folder named “Results/YYYY-MM-DD_HH-MM” with all files inside. \# You
can specify a different output directory if desired

save_project_results(df_calc, df_tank, params, output_dir =
“My_Results”)

# This creates a folder named “My_Results/YYYY-MM-DD_HH-MM” with all files inside.

# Conclusion

At the end of the analysis, you will have:
- Individual Fish Data CSV
- Tank Averages CSV
- Final Journal-ready formated Table CSV
- Detailed Statistics Report TXT

\*\*\* The report text file provides detailed ANOVA/Kruskal-Wallis
outputs for each parameter analyzed. \*\*\*

# Here is an example of what the detailed statistics report looks like:

<details>

<summary>

<b>Click here to view a sample Statistical Report</b>
</summary>

<br>

``` text
-------------------------------------------------
ANALYSIS FOR: mean_weight_final 
-------------------------------------------------
Method Used: ANOVA 

         ```mean_weight_final   ```groups    ```treatment
```Diet_C         45.01           a        Diet_C```
```Diet_B         38.37           b        Diet_B```
```Diet_A         30.62           c        Diet_A```
```Control        30.10           c        Control```
```

(See CSV files for Mean ± SE values) \`\`\`
