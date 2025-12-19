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
    message("Open this file in Excel, fill in your data, and use import_fish_data() to load it.")
  }
}
