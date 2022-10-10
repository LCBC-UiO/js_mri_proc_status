#!/usr/bin/env Rscript
source("utils.R")
args <- get_args()
args_orig <- args
proc  <- read_json("protocol.json")
tasks <- read_json("tasks.json")
data  <- read_json("data.json")

for (key in c("sub", "ses", "project_id", "wave_code")) {
  idx <- which(names(args) %in% key)
  if (length(idx) != 0) {
    assign(key, args[idx])
    args <- args[idx * -1]
  }
}
sub_dt <- data[[sub]][[ses]]
if(any(!exists("project_id"), !exists("wave_code"))){
  project_id <- sub_dt$project_id
  wave_code <- sub_dt$wave_code
}
proc <- proc[[project_id]][[wave_code]]
types <- sapply(proc, function(x) {
  k <- tasks[[x]]$value
  if (!is.null(tasks[[x]]$comments) &&
      tasks[[x]]$comments == "yes") {
    k <- c(k, setNames("asis", "comments"))
  }
  k
})
types <- unlist(types)
names(types) <- gsub("\\.", "_", names(types))
names(types) <- gsub("1$", "", names(types))
error_col <- names(args)[which(!names(args) %in% names(types))]
status <- 200
out <- ""
if (any(!c(exists("sub"), exists("ses")))) {
  status <- 205
} else if (any(!c(exists("project_id"), exists("wave_code")))) {
  status <- 205
} else if (length(args_orig) == 0) {
  status <- 202
} else if (length(error_col) != 0) {
  status <- 203
}

if (status == 205) {
  msg <-
    "No 'project_id' or 'wave_code' pair was provided for updating the data."
} else if (status == 202) {
  msg <- "No key-value pairs were provided for updating the data."
} else if (status == 203) {
  out <- tojson(error_col)
  msg <- sprintf("'Process tags dont exist. Check spelling in: %s'",
                 paste0(error_col, collapse = ","))
} else if (status == 200) {
  if(is.null(data[[sub]][[ses]])){
    data[[sub]][[ses]] <- list()
  }
  data[[sub]][[ses]]["project_id"] <- project_id
  data[[sub]][[ses]]["wave_code"] <- wave_code
  err_vals <- list()
  for (i in seq_along(args)) {
    value <- args[i]
    key <- names(args)[i]
    ctype <- unname(types[names(types) == key])
    val_ok <- FALSE
    if (ctype == "icons") {
      val_ok <- value %in% c("fail", "ok", "rerun")
    } else if (ctype == "numeric") {
      val_ok <- !is.na(as.numeric(value))
    } else if (ctype == "asis") {
      val_ok <- TRUE
    } else if (Array.isArray(ctype)) {
      val_ok <- value %in% ctype
    }
    if (val_ok) {
      keypair <- list(value)
      names(keypair) <- key
      session <- list(keypair)
      names(session) <- ses
      # if sub & ses already exists in json
      if (!is.null(data[[sub]]) && !is.null(data[[sub]][[ses]])) {
        data[[sub]][[ses]][[key]] <- value
        # if sub only exists and not session
      } else if (!is.null(data[[sub]])) {
        data[[sub]] <- c(data[[sub]], session)
        #if sub does not exist
      } else{
        j <- length(data) + 1
        data[[j]] <- session
        names(data)[j] <- sub
      }
    } else{
      err_vals <- c(err_vals, args[i])
    }
  }
  if (length(err_vals) > 0) {
    out <- tojson(err_vals)
    status <- 204
    msg <-
      "Some values do not correspond to values for the given process."
  } else{
    data <- sort_data(data, names(types))
    write_json(data, "data.json")
    entry <- list(data[[sub]][ses])
    names(entry) <- sub
    out <- tojson(entry)
    status <- 201
    msg <- sprintf("Progress updated for %s %s", sub, ses)
  }
}

cat(
  sprintf("Content-Type: application/json; charset=UTF-8\r"),
  sprintf("Status: %s\r", status),
  sprintf("Message : %s\r", msg),
  "\r",
  out,
  sep = "\n"
)
