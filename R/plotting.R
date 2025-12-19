#' Plot Treatment Comparisons (Boxplot + Points)
#'
#' Visualizes the distribution of a parameter across treatments.
#' Includes individual data points to show tank variance.
#'
#' @param df Dataframe (tank level).
#' @param parameter String. The column name to plot (e.g. "mean_sgr").
#' @param y_label String. Label for the Y-axis.
#' @import ggplot2
#' @export
plot_treatment_comparison <- function(df, parameter, y_label = NULL) {

  if(is.null(y_label)) y_label <- parameter

  # Ensure parameter exists
  if(!parameter %in% names(df)) stop(paste("Column", parameter, "not found in dataframe."))

  p <- ggplot(df, aes(x = treatment, y = .data[[parameter]], fill = treatment)) +
    geom_boxplot(alpha = 0.6, outlier.shape = NA) + # Hide outliers in boxplot to avoid duplication
    geom_jitter(width = 0.2, size = 2, alpha = 0.8) + # Show actual tank points
    theme_minimal() +
    labs(y = y_label, x = "Treatment", title = paste("Comparison of", parameter)) +
    theme(legend.position = "none")

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
