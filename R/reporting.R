#' Generate Summary Table with Units
#'
#' Summarizes parameters with Mean ± SE and significance letters.
#' Automatically renames variables to professional formats with units.
#'
#' @param df_tank Dataframe. The tank-level aggregated data.
#' @param params_list Vector of strings. Names of parameters to analyze (e.g., c("SGR", "FCR")).
#' @param error_type String. "SE" (Standard Error) or "SD" (Standard Deviation).
#' @return A clean dataframe ready for export.
#' @importFrom dplyr group_by summarise mutate n
#' @importFrom tidyr pivot_wider
#' @export
generate_summary_table <- function(df_tank, params_list, error_type = "SE") {

  # --- UNITS DICTIONARY (Matches New Process.R Names) ---
  units_map <- list(
    # Growth
    "Final_Weight"       = "Final Weight (g)",
    "Initial_Weight"     = "Initial Weight (g)",
    "Weight_Gain"        = "Weight Gain (%)",
    "Total_Biomass_Gain" = "Total Biomass Gain (g)",
    "SGR"                = "SGR (%/day)",
    "Final_Length"       = "Final Length (cm)",

    # Efficiency
    "FCR"                = "FCR",
    "PER"                = "PER",
    "Feed_Intake"        = "Total Feed Intake (g/fish)",

    # Health / Indexes
    "Survival"           = "Survival (%)",
    "HSI"                = "Hepatosomatic Index (%)",
    "VSI"                = "Viscerosomatic Index (%)",
    "PFR"                = "Peritoneal Fat Ratio (%)",
    "Cond_Factor"        = "Condition Factor (K)",

    # Immune / Antioxidant (Future Proofing)
    "Lysozyme"           = "Lysozyme (U/mL)",
    "SOD"                = "SOD Activity (%)",
    "CAT"                = "CAT Activity (U/mg protein)"
  )

  final_table <- data.frame()

  for(param in params_list) {
    tryCatch({
      # 1. Check if parameter exists in the dataframe
      if(!param %in% names(df_tank)) {
        message(paste("⚠️ Warning: Parameter", param, "not found in dataframe. Skipping."))
        next
      }

      # 2. Run Stats to get letters
      stats_res <- run_stats_smart(df_tank, param)
      letters_df <- stats_res$groups

      # 3. Calculate Means and Error
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

      # 4. Merge Letters
      merged <- merge(summary_data, letters_df, by = "treatment")

      # 5. Format: "12.50 ± 0.30 ᵃ" (Using superscript for letters)
      # Note: \u00B1 is the unicode for the ± symbol
      merged$formatted <- paste0(
        sprintf("%.2f", merged$mean_val), " \u00B1 ",
        sprintf("%.2f", merged$error_val),
        " <sup>", merged$groups, "</sup>"
      )

      # 6. Prepare Row
      row_data <- merged[, c("treatment", "formatted")]

      # USE THE DICTIONARY TO RENAME PARAMETER
      clean_name <- if(!is.null(units_map[[param]])) units_map[[param]] else param
      row_data$parameter <- clean_name

      final_table <- rbind(final_table, row_data)

    }, error = function(e) {
      message(paste("❌ Error processing", param, ":", e$message))
    })
  }

  # Pivot to Wide Format (Treatments as Columns)
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
