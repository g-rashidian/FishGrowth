#' Get Standard Data Template
#'
#' Copies a blank CSV template to the user's working directory.
#' The user can then fill this file with their experimental data.
#'
#' @param filename String. The name of the file to save (default: "data_template.csv").
#' @return Invisible. Copies the file.
#' @export
get_data_template <- function(filename = "data_template.csv") {

  # Find the file inside the installed package
  template_path <- system.file("extdata", "fish_growth_template.csv", package = "FishGrowth")

  if (template_path == "") {
    stop("Template file not found. Try reinstalling the package.")
  }

  # Copy it to the user's current folder
  if (file.exists(filename)) {
    warning(paste("File", filename, "already exists. Skipped to avoid overwriting."))
  } else {
    file.copy(from = template_path, to = filename)
    message(paste("✅ Template saved as:", filename))
    message("   -> Open this file in Excel, fill in your data, and use import_fish_data() to load it.")
  }
}

#' Get Master Analysis Script
#'
#' Copies the standard analysis script to your current working directory.
#' Use this script to run the full analysis workflow.
#'
#' @param filename String. Name of the file to save (default: "Analysis_Workflow.R").
#' @return NULL. Saves a file to the working directory.
#' @export
get_analysis_template <- function(filename = "Analysis_Workflow.R") {

  # Locate the file inside the installed package
  # Note: You must ensure you saved the script in 'inst/templates/master_script.R'
  script_path <- system.file("templates", "master_script.R", package = "FishGrowth")

  if (script_path == "") {
    stop("Could not find the template script in the package. Did you create 'inst/templates/master_script.R'?")
  }

  # Copy it to the user's folder
  if (file.exists(filename)) {
    warning(paste("File", filename, "already exists. Skipping to prevent overwrite."))
  } else {
    file.copy(script_path, filename)
    message(paste("✅ Analysis script saved as:", filename))
    message("   -> Open this file in RStudio to start your analysis!")
  }
}
