#' Print the FishGrowth Workflow Guide
#'
#' Displays a cheat sheet of the package functions in the correct order of execution.
#'
#' @return Prints text to the console.
#' @export
fishgrowth_guide <- function() {
  cat("====================================================================\n")
  cat("                  🐟 FishGrowth Package Guide 🐟\n")
  cat("====================================================================\n\n")

  cat("STEP 0: PREPARE\n")
  cat("  get_data_template('my_study.csv')\n")
  cat("    -> Saves a blank standard Excel/CSV file to your folder.\n\n")

  cat("STEP 1: IMPORT\n")
  cat("  df <- import_fish_data('my_study.csv')\n")
  cat("    -> Loads data and standardizes column names.\n\n")

  cat("STEP 2: CALCULATE\n")
  cat("  df_calc <- calculate_metrics(df, days = 60)\n")
  cat("    -> Computes SGR, Weight Gain, K, etc. per fish.\n\n")

  cat("STEP 3: AGGREGATE (Critical)\n")
  cat("  df_tank <- aggregate_tank_data(df_calc)\n")
  cat("    -> Averages fish into Tanks (the correct statistical unit).\n\n")

  cat("STEP 4: VISUALIZE\n")
  cat("  plot_treatment_comparison(df_tank, 'mean_weight_final')\n")
  cat("    -> Shows Boxplots + Dotplots for any parameter.\n\n")

  cat("STEP 5: ANALYZE\n")
  cat("  generate_summary_table(df_tank, c('mean_weight_final', 'fcr'))\n")
  cat("    -> Runs ANOVA/Stats and generates the 'Mean ± SE' table.\n\n")

  cat("STEP 6: SAVE\n")
  cat("  save_project_results(df_calc, df_tank, final_table)\n")
  cat("    -> Exports all CSVs, Graphs, and Stats to a 'Results' folder.\n")

  cat("\n====================================================================\n")
}
