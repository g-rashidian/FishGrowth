#' Export Full Project Results
#'
#' Saves all analysis artifacts to a timestamped folder.
#' Includes: Individual data, Tank averages, Final Journal Table, and Detailed Stats.
#'
#' @param df_calc Dataframe. The individual fish data (processed).
#' @param df_tank Dataframe. The tank-level averages.
#' @param final_table Dataframe. The specific "Mean ± SE" table generated earlier.
#' @param raw_stats_list List. (Optional) If you want to save full ANOVA tables, pass the results of run_stats_smart here.
#' @param output_dir String. Base directory for output (default is "Results").
#' @importFrom utils write.csv capture.output
#' @export
save_project_results <- function(df_calc, df_tank, final_table, output_dir = "Results") {

  # 1. Create a unique folder with timestamp
  timestamp <- format(Sys.time(), "%Y-%m-%d_%H-%M")
  save_path <- file.path(output_dir, timestamp)

  if(!dir.exists(save_path)) dir.create(save_path, recursive = TRUE)

  # 2. Save Dataframes (CSVs)
  write.csv(df_calc, file.path(save_path, "01_individual_fish_data.csv"), row.names = FALSE)
  write.csv(df_tank, file.path(save_path, "02_tank_averages.csv"), row.names = FALSE)
  write.csv(final_table, file.path(save_path, "03_final_journal_table.csv"), row.names = FALSE)

  message(paste("✅ Data files saved to:", save_path))

  # 3. Save Detailed Statistics (Text File)
  # This loops through all numeric columns in df_tank and runs the stats again
  # just to capture the full ANOVA/Kruskal output into a text file.

  stats_file <- file.path(save_path, "04_detailed_statistics.txt")

  sink(stats_file) # Redirect R output to the text file
  cat("=================================================\n")
  cat("       DETAILED STATISTICAL REPORT               \n")
  cat("=================================================\n\n")

  numeric_cols <- names(df_tank)[sapply(df_tank, is.numeric)]
  # Exclude ID columns if they were accidentally detected as numeric
  numeric_cols <- numeric_cols[!numeric_cols %in% c("initial_n", "final_n")]

  for(param in numeric_cols) {
    cat(paste("\n-------------------------------------------------\n"))
    cat(paste("ANALYSIS FOR:", param, "\n"))
    cat(paste("-------------------------------------------------\n"))

    # We use tryCatch to skip columns that might be constant or error-prone
    tryCatch({
      # Re-run the stats wrapper to get the method details
      res <- run_stats_smart(df_tank, param)

      cat(paste("Method Used:", res$method, "\n\n"))

      # If it was ANOVA, print the summary table
      # (We access the internal model if needed, or just the groups)
      print(res$groups)
      cat("\n(See CSV files for Mean ± SE values)\n")

    }, error = function(e) {
      cat(paste("Could not run stats:", e$message, "\n"))
    })
  }

  sink() # Stop redirecting
  message("✅ Detailed statistics text file saved.")
}
