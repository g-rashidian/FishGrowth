# ==============================================================================
# MASTER ANALYSIS SCRIPT - FISHGROWTH V2.0
# ==============================================================================

library(FishGrowth)
library(ggplot2)

# 1. SETUP
# ------------------------------------------------------------------------------
# define your settings here
my_filename   <- "experiment_data.csv"  # CHANGE THIS to your actual file name
days_duration <- 60                     # How long was the experiment?

# (Optional) If you don't have a file yet, run this to get the blank template:
# get_data_template("experiment_data.csv")


# 2. IMPORT & PROCESS
# ------------------------------------------------------------------------------
# Load the data
df <- import_fish_data(my_filename)

# Calculate individual fish metrics (SGR, Weight Gain, K, etc.)
df_fish <- calculate_metrics(df, days = days_duration)

# Aggregate to Tank Level (This now generates Clean Names like SGR, FCR)
df_tank <- aggregate_tank_data(df_fish)

# Check the new names!
print(names(df_tank))

# 3. VISUALIZATION
# ------------------------------------------------------------------------------
# Use the NEW names here
print(plot_treatment_comparison(df_tank, "Final_Weight", "Final Weight (g)"))
print(plot_treatment_comparison(df_tank, "SGR", "SGR (%/day)"))
print(plot_treatment_comparison(df_tank, "FCR", "FCR"))

# 4. REPORTING
# ------------------------------------------------------------------------------
# List the parameters using the NEW names
my_params <- c("Final_Weight", "SGR", "FCR", "Survival", "HSI", "Cond_Factor")

# Generate the table
final_table <- generate_summary_table(df_tank, my_params)
print(final_table)

# 5. SAVE
# ------------------------------------------------------------------------------
# Saves CSVs, Tables, Plots, and Stats Report to a timestamped folder
save_project_results(df_fish, df_tank, final_table, output_dir = "Results")
