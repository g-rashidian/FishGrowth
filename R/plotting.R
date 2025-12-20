#' Plot Treatment Comparisons with Significance Letters
#'
#' Visualizes the distribution of a parameter and adds statistical significance letters.
#'
#' @param df Dataframe (tank level).
#' @param parameter String. The column name to plot.
#' @param y_label String. Label for the Y-axis.
#' @import ggplot2
#' @importFrom dplyr group_by summarise
#' @export
plot_treatment_comparison <- function(df, parameter, y_label = NULL) {

  if(is.null(y_label)) y_label <- parameter

  # 1. Run Stats to get the letters
  # We suppress messages so the console stays clean
  stats_res <- suppressMessages(run_stats_smart(df, parameter))
  letters_df <- stats_res$groups

  # 2. Calculate position for the letters (Above the highest point of each group)
  # We find the max value per treatment to know where to put the "a"
  label_positions <- df %>%
    dplyr::group_by(treatment) %>%
    dplyr::summarise(max_val = max(!!dplyr::sym(parameter), na.rm = TRUE)) %>%
    merge(letters_df, by = "treatment")

  # Add a little buffer so the letter sits above the boxplot (10% of max height)
  buffer <- max(df[[parameter]], na.rm = TRUE) * 0.1
  label_positions$y_pos <- label_positions$max_val + buffer

  # 3. Plot
  p <- ggplot(df, aes(x = treatment, y = .data[[parameter]], fill = treatment)) +
    geom_boxplot(alpha = 0.6, outlier.shape = NA) +
    geom_jitter(width = 0.2, size = 2, alpha = 0.8) +
    # Add the letters
    geom_text(data = label_positions,
              aes(x = treatment, y = y_pos, label = groups),
              size = 6, color = "black", fontface = "bold") +
    theme_minimal() +
    labs(y = y_label, x = "Treatment", title = paste("Analysis of", parameter)) +
    theme(legend.position = "none",
          axis.text.x = element_text(size = 12, face = "bold"),
          axis.title = element_text(size = 14))

  return(p)
}

#' Plot Normality Check (Q-Q Plot)
#'
#' Visualizes residuals to check for normality assumptions.
#'
#' @param df Dataframe (tank level).
#' @param parameter String. The column name to test.
#' @import ggplot2
#' @importFrom stats lm residuals
#' @export
plot_normality <- function(df, parameter) {

  # Build a simple linear model to get residuals
  f <- as.formula(paste(parameter, "~ treatment"))
  model <- lm(f, data = df)
  resids <- data.frame(residuals = residuals(model))

  p <- ggplot(resids, aes(sample = residuals)) +
    stat_qq() +
    stat_qq_line(color = "red") +
    theme_minimal() +
    labs(title = paste("Q-Q Plot for", parameter),
         subtitle = "Points should follow the red line for Normal Distribution")

  return(p)
}
