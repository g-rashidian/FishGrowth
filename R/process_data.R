#' Calculate Growth and Health Indices
#'
#' @param df Dataframe containing individual fish data.
#' @param days Numeric. Duration of the experiment in days.
#' @return Dataframe with calculated columns (WG, SGR, K, HSI, etc.).
#' @export
calculate_metrics <- function(df, days) {
  # Ensure standard naming (lowercase) to prevent case-sensitivity errors
  names(df) <- tolower(names(df))

  # 1. Growth Metrics
  if("weight_final_g" %in% names(df) & "weight_initial_g" %in% names(df)) {
    df$weight_gain_g <- df$weight_final_g - df$weight_initial_g
    df$weight_gain_pct <- (df$weight_gain_g / df$weight_initial_g) * 100
    df$sgr <- ((log(df$weight_final_g) - log(df$weight_initial_g)) / days) * 100
  }

  # 2. Somatic Indices
  if("weight_final_g" %in% names(df) & "length_final_cm" %in% names(df)) {
    df$condition_factor <- 100 * (df$weight_final_g / (df$length_final_cm^3))
  }
  
  # Health indices (Check if columns exist before calculating)
  if("liver_weight_g" %in% names(df)) {
    df$hsi <- (df$liver_weight_g / df$weight_final_g) * 100
  }
  if("viscera_weight_g" %in% names(df)) {
    df$vsi <- (df$viscera_weight_g / df$weight_final_g) * 100
  }
  if("fat_weight_g" %in% names(df)) {
    df$pfr <- (df$fat_weight_g / df$weight_final_g) * 100
  }

  return(df)
}

#' Aggregate Data to Tank Level
#'
#' Averages individual fish data per tank to avoid pseudo-replication.
#' Renames variables to standard scientific formats (e.g., SGR, FCR).
#'
#' @param df Processed dataframe from calculate_metrics.
#' @return Dataframe aggregated by Tank and Treatment.
#' @importFrom dplyr group_by summarise mutate ungroup first
#' @export
aggregate_tank_data <- function(df) {
  
  # Ensure required columns exist to avoid crashing
  required_cols <- c("treatment", "tank_id")
  if(!all(required_cols %in% names(df))) {
    stop("Error: Dataframe must contain 'treatment' and 'tank_id' columns.")
  }

  tank_means <- df %>%
    dplyr::group_by(treatment, tank_id) %>%
    dplyr::summarise(
      # --- Growth Parameters (Renamed to Scientific Format) ---
      Final_Weight   = mean(weight_final_g, na.rm = TRUE),
      Initial_Weight = mean(weight_initial_g, na.rm = TRUE),
      Weight_Gain    = mean(weight_gain_pct, na.rm = TRUE),
      Total_Biomass_Gain = sum(weight_gain_g, na.rm = TRUE),
      SGR            = mean(sgr, na.rm = TRUE),
      
      # --- Health & Indexes ---
      # We use 'if' checks inside mean() to handle missing columns gracefully
      HSI            = if("hsi" %in% names(.)) mean(hsi, na.rm = TRUE) else NA,
      VSI            = if("vsi" %in% names(.)) mean(vsi, na.rm = TRUE) else NA,
      PFR            = if("pfr" %in% names(.)) mean(pfr, na.rm = TRUE) else NA,
      Cond_Factor    = if("condition_factor" %in% names(.)) mean(condition_factor, na.rm = TRUE) else NA,

      # --- Feed & Survival Inputs ---
      # Using 'first' because these are usually tank-level constants
      Feed_Intake    = if("feed_intake_tank_g" %in% names(.)) dplyr::first(feed_intake_tank_g) else NA,
      Protein_Pct    = if("protein_content_pct" %in% names(.)) dplyr::first(protein_content_pct) else NA,
      Initial_N      = if("initial_fish_count" %in% names(.)) dplyr::first(initial_fish_count) else NA,
      Final_N        = if("final_fish_count" %in% names(.)) dplyr::first(final_fish_count) else NA
    ) %>%
    
    # --- Calculated Efficiency Metrics ---
    dplyr::mutate(
      FCR = Feed_Intake / Total_Biomass_Gain,
      PER = Total_Biomass_Gain / (Feed_Intake * (Protein_Pct / 100)), # Adjusted for percentage
      Survival = (Final_N / Initial_N) * 100
    ) %>%
    
    # Remove columns that are completely empty (optional, keeps it clean)
    dplyr::select(where(~!all(is.na(.)))) %>%
    dplyr::ungroup()

  return(tank_means)
}
