#' Import and Standardize Fish Data
#'
#' Reads CSV or Excel files and standardizes column names to snake_case.
#' Checks for common issues like missing values.
#'
#' @param file_path String. Path to the input file (.csv or .xlsx).
#' @return A dataframe with standardized column names.
#' @importFrom readxl read_excel
#' @importFrom utils read.csv
#' @export
import_fish_data <- function(file_path) {

  # 1. Detect file type and read
  if (grepl("\\.csv$", file_path, ignore.case = TRUE)) {
    df <- utils::read.csv(file_path, stringsAsFactors = FALSE)
  } else if (grepl("\\.xlsx?$", file_path, ignore.case = TRUE)) {
    # Check if readxl is installed (it's in Suggests usually, but we forced it in Imports)
    df <- readxl::read_excel(file_path)
  } else {
    stop("File format not supported. Please use .csv or .xlsx")
  }

  # 2. Standardize Column Names
  # Convert to lowercase and replace dots/spaces with underscores
  old_names <- colnames(df)
  new_names <- tolower(old_names)
  new_names <- gsub("[\\. ]+", "_", new_names) # Replace . or space with _
  colnames(df) <- new_names

  # 3. Basic Validation
  # Check for empty columns or rows
  if (nrow(df) == 0) warning("Imported dataset is empty.")

  # Check for NA values in critical columns if they exist
  critical_cols <- c("treatment", "tank_id", "weight_initial_g", "weight_final_g")
  for (col in critical_cols) {
    if (col %in% colnames(df)) {
      na_count <- sum(is.na(df[[col]]))
      if (na_count > 0) {
        warning(paste("Found", na_count, "missing values in column:", col))
      }
    }
  }

  message(paste("Successfully imported:", basename(file_path)))
  return(df)
}
