#' Calculate Growth and Health Indices
#'
#' @param df Dataframe containing individual fish data.
#' @param days Numeric. Duration of the experiment in days.
#' @return Dataframe with calculated columns (WG, SGR, K, HSI, etc.).
#' @export
calculate_metrics <- function(df, days) {
  # Ensure standard naming (lowercase)
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
#'
#' @param df Processed dataframe from calculate_metrics.
#' @return Dataframe aggregated by Tank and Treatment.
#' @importFrom dplyr group_by summarise mutate ungroup first
#' @export
aggregate_tank_data <- function(df) {
  # Check if dplyr is installed; if not, stop or use ::
  # (Ideally, we add dplyr to Imports in Step 4)

  tank_means <- df %>%
    dplyr::group_by(treatment, tank_id) %>%
    dplyr::summarise(
      mean_weight_final = mean(weight_final_g, na.rm = TRUE),
      mean_weight_gain_pct = mean(weight_gain_pct, na.rm = TRUE),
      mean_sgr = mean(sgr, na.rm = TRUE),
      mean_hsi = mean(hsi, na.rm = TRUE),
      mean_vsi = mean(vsi, na.rm = TRUE),
      mean_pfr = mean(pfr, na.rm = TRUE),
      mean_cf = mean(condition_factor, na.rm = TRUE),

      feed_intake = dplyr::first(feed_intake_tank_g),
      protein_pct = dplyr::first(protein_content_pct),
      initial_n = dplyr::first(initial_fish_count),
      final_n = dplyr::first(final_fish_count),
      total_tank_gain = sum(weight_gain_g, na.rm = TRUE)
    ) %>%
    dplyr::mutate(
      fcr = feed_intake / total_tank_gain,
      per = total_tank_gain / (feed_intake * protein_pct),
      survival_rate = (final_n / initial_n) * 100
    ) %>%
    dplyr::ungroup()

  return(tank_means)
}
