#' Export Full Project Results (Data, Tables, Plots, and Stats)
#'
#' Saves all analysis artifacts to a timestamped folder.
#' Includes: CSVs, Journal Table, PNG Plots, and Detailed Statistical Report.
#'
#' @param df_calc Dataframe. Individual fish data.
#' @param df_tank Dataframe. Tank-level averages.
#' @param final_table Dataframe. The final summary table.
#' @param output_dir String. Base directory (default "Results").
#' @importFrom utils write.csv capture.output
#' @importFrom ggplot2 ggsave
#' @export
save_project_results <- function(df_calc, df_tank, final_table, output_dir = "Results") {

  # 1. Create Folder
  timestamp <- format(Sys.time(), "%Y-%m-%d_%H-%M")
  save_path <- file.path(output_dir, timestamp)
  if(!dir.exists(save_path)) dir.create(save_path, recursive = TRUE)

  # 2. Save Data Tables (CSVs)
  write.csv(df_calc, file.path(save_path, "01_individual_fish_data.csv"), row.names = FALSE)
  write.csv(df_tank, file.path(save_path, "02_tank_averages.csv"), row.names = FALSE)
  write.csv(final_table, file.path(save_path, "03_final_journal_table.csv"), row.names = FALSE)

  message(paste("✅ Data tables saved to:", save_path))

  # 3. Save Detailed Statistics (Text File)
  stats_file <- file.path(save_path, "04_detailed_statistics.txt")

  # Identify numeric columns to analyze
  numeric_cols <- names(df_tank)[sapply(df_tank, is.numeric)]
  numeric_cols <- numeric_cols[!numeric_cols %in% c("initial_n", "final_n")]

  sink(stats_file) # Redirect output to text file

  cat("=================================================\n")
  cat("       DETAILED STATISTICAL REPORT               \n")
  cat("=================================================\n\n")

  for(param in numeric_cols) {
    cat(paste("\n-------------------------------------------------\n"))
    cat(paste("ANALYSIS FOR:", param, "\n"))
    cat(paste("-------------------------------------------------\n"))

    tryCatch({
      # Run stats and print the raw result
      res <- run_stats_smart(df_tank, param)
      cat(paste("Method Used:", res$method, "\n\n"))
      print(res$groups)

    }, error = function(e) {
      cat(paste("Could not run stats:", e$message, "\n"))
    })
  }
  sink() # Stop redirecting
  message("✅ Detailed statistics text file saved.")

  # 4. Generate and Save Plots automatically
  plot_dir <- file.path(save_path, "Plots")
  if(!dir.exists(plot_dir)) dir.create(plot_dir)

  message("📊 Generating and saving plots...")

  for(param in numeric_cols) {
    tryCatch({
      # Generate plot with letters
      p <- plot_treatment_comparison(df_tank, param)

      # Save it
      filename <- paste0("Plot_", param, ".png")
      ggsave(filename, plot = p, path = plot_dir, width = 6, height = 5, dpi = 300)

    }, error = function(e) {
      # Skip if plotting fails
    })
  }

  message("✅ Plots saved with significance letters.")
}
