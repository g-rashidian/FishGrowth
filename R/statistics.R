#' Run ANOVA and Post-Hoc Analysis
#'
#' Checks assumptions and runs appropriate stats.
#'
#' @param df Dataframe (tank level).
#' @param parameter String. Name of the column to analyze.
#' @param post_hoc String. "tukey" or "duncan".
#' @importFrom stats aov shapiro.test kruskal.test sd lm residuals
#' @importFrom agricolae duncan.test HSD.test
#' @importFrom car leveneTest
#' @export
run_stats_smart <- function(df, parameter, post_hoc = "duncan") {

  # Prepare formula
  f <- as.formula(paste(parameter, "~ treatment"))

  # 1. Assumptions
  model_lm <- lm(f, data = df)
  shapiro_p <- shapiro.test(residuals(model_lm))$p.value
  levene_p <- car::leveneTest(f, data = df)$`Pr(>F)`[1]

  # 2. Test Selection
  if(shapiro_p > 0.05 && levene_p > 0.05) {
    # ANOVA
    model <- aov(f, data = df)
    res_anova <- summary(model)
    p_val <- res_anova[[1]][["Pr(>F)"]][1]

    # Post-hoc
    if(post_hoc == "duncan") {
      groups <- agricolae::duncan.test(model, "treatment", group=TRUE)$groups
    } else {
      groups <- agricolae::HSD.test(model, "treatment", group=TRUE)$groups
    }

    groups$treatment <- rownames(groups)
    test_name <- "ANOVA"

  } else {
    # Non-Parametric
    kruskal <- kruskal.test(f, data = df)
    p_val <- kruskal$p.value
    # Placeholder for non-parametric post-hoc if needed
    groups <- data.frame(treatment = unique(df$treatment), groups = "")
    test_name <- "Kruskal-Wallis"
  }

  return(list(p_value = p_val, groups = groups, method = test_name))
}
