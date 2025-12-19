#' Generate Summary Table for Journal
#'
#' Summarizes parameters with Mean ± SE (or SD) and significance letters.
#'
#' @param df_tank Dataframe. The tank-level aggregated data.
#' @param params_list Vector of strings. Names of parameters to analyze (e.g. c("mean_sgr", "fcr")).
#' @param error_type String. "SE" (Standard Error) or "SD" (Standard Deviation).
#' @return A clean dataframe ready for export.
#' @importFrom dplyr group_by summarise mutate n
#' @importFrom tidyr pivot_wider
#' @export
generate_summary_table <- function(df_tank, params_list, error_type = "SE") {

  final_table <- data.frame()

  for(param in params_list) {
    # 1. Run Stats to get letters
    # We catch errors in case a parameter is constant or has issues
    tryCatch({
      stats_res <- run_stats_smart(df_tank, param)
      letters_df <- stats_res$groups

      # 2. Calculate Means and Error
      summary_data <- df_tank %>%
        dplyr::group_by(treatment) %>%
        dplyr::summarise(
          mean_val = mean(!!dplyr::sym(param), na.rm = TRUE),
          sd_val = sd(!!dplyr::sym(param), na.rm = TRUE),
          n_val = dplyr::n()
        ) %>%
        dplyr::mutate(
          se_val = sd_val / sqrt(n_val),
          error_val = if(error_type == "SE") se_val else sd_val
        )

      # 3. Merge Letters
      merged <- merge(summary_data, letters_df, by = "treatment")

      # 4. Format: "12.50 ± 0.30 a"
      merged$formatted <- paste0(
        sprintf("%.2f", merged$mean_val), " ± ",
        sprintf("%.2f", merged$error_val), " ",
        merged$groups
      )

      # 5. Clean up for the final row
      row_data <- merged[, c("treatment", "formatted")]
      row_data$parameter <- param

      final_table <- rbind(final_table, row_data)

    }, error = function(e) {
      message(paste("Skipping parameter:", param, "- Error:", e$message))
    })
  }

  # Pivot to Wide Format (Treatments as columns)
  if(nrow(final_table) > 0) {
    final_wide <- tidyr::pivot_wider(
      final_table,
      names_from = treatment,
      values_from = formatted,
      id_cols = parameter
    )
    return(final_wide)
  } else {
    return(NULL)
  }
}
