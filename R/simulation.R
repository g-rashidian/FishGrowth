#' Create Simulated Fish Data with Known Effects
#'
#' Generates a dataset with specified number of replicates and significant differences.
#' Useful for testing statistical power or demonstrating the package.
#'
#' @param n_reps Integer. Number of tanks per treatment (default 5).
#' @param n_fish Integer. Number of fish per tank (default 15).
#' @return A dataframe ready for export or analysis.
#' @importFrom stats rnorm runif
#' @export
create_simulation_data <- function(n_reps = 5, n_fish = 15) {

  treatments <- c("Control", "Diet_A", "Diet_B", "Diet_C")
  n_treats <- length(treatments)
  total_tanks <- n_treats * n_reps
  total_fish <- total_tanks * n_fish

  # 1. Create Design
  df <- data.frame(
    tank_id = rep(paste0("T", 1:total_tanks), each = n_fish),
    treatment = rep(treatments, each = n_reps * n_fish),
    fish_id = 1:total_fish,
    initial_fish_count = n_fish,
    final_fish_count = n_fish # Assuming 100% survival for simplicity
  )

  # 2. Add Biased Growth Data (The "Known Difference")
  # Base weight ~10g.
  # Control & Diet_A -> Final ~30g (Low growth)
  # Diet_B -> Final ~38g (Medium growth)
  # Diet_C -> Final ~45g (High growth)

  # Helper to generate weights based on treatment
  generate_weights <- function(trt) {
    if(trt == "Control") return(rnorm(1, 30, 3))
    if(trt == "Diet_A")  return(rnorm(1, 31, 3)) # No Sig Diff from Control
    if(trt == "Diet_B")  return(rnorm(1, 38, 3)) # Significant
    if(trt == "Diet_C")  return(rnorm(1, 45, 3)) # Very Significant
  }

  # Apply the logic row by row (vectorized would be faster, but this is clearer for logic)
  df$weight_initial_g <- round(rnorm(total_fish, 10, 1), 2)
  df$weight_final_g <- round(sapply(df$treatment, generate_weights), 2)

  # 3. Add Other Metrics (correlated to weight)
  # Feed Intake (Larger fish eat more)
  # We simulate this at tank level, but populate it per fish for the CSV format
  tank_feed <- data.frame(
    tank_id = unique(df$tank_id),
    feed_intake_tank_g = NA
  )

  for(i in 1:nrow(tank_feed)) {
    # Find average weight of this tank to estimate feed needed
    t_id <- tank_feed$tank_id[i]
    avg_w <- mean(df$weight_final_g[df$tank_id == t_id])
    # FCR roughly 1.5
    tank_feed$feed_intake_tank_g[i] <- (avg_w - 10) * n_fish * 1.5
  }

  # Merge feed back
  df <- merge(df, tank_feed, by = "tank_id")

  df$length_final_cm <- round(10 + (df$weight_final_g / 5), 1)
  df$liver_weight_g <- round(df$weight_final_g * 0.02, 2)
  df$viscera_weight_g <- round(df$weight_final_g * 0.06, 2)
  df$fat_weight_g <- round(df$weight_final_g * 0.015, 2)
  df$protein_content_pct <- 0.45

  return(df)
}
