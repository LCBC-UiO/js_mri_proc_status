#!/usr/bin/env Rscript
datadir <- Sys.getenv("DATADIR")

args <- commandArgs(trailingOnly = TRUE)
args <- gsub("^=", "", args)
args <- unlist(strsplit(args, "\\&"))
args <- setNames(
        sapply(args, function(x) strsplit(x, "=")[[1]][2]),
        sapply(args, function(x) strsplit(x, "=")[[1]][1])
)
sub  <- sprintf("sub-%s", gsub("sub-", "", args["sub"]))
ses  <- sprintf("ses-%s", gsub("ses-", "", args["ses"]))
args <- args[-1:-2]
args <- na.omit(args)

sort_data <- function(x){
    .name_order <- function(x) x[order(names(x))]
    x <- .name_order(x)
    x <- lapply(x, .name_order)
    lapply(x, function(y){
        lapply(y, function(p){
            p[na.omit(match(names(proc), names(p)))]
        })
    })
}

proc <- jsonlite::read_json(file.path(datadir, "process.json"),
    simplifyVector = TRUE)
types <- sapply(proc, function(x){
   if(length(x) > 1)
    return("custom array")
   unname(x)
})
data <- jsonlite::read_json(file.path(datadir, "data.json"))
error_col <- names(args)[which(!names(args) %in% names(proc))]
if(sub == "sub-" || ses == "ses-"){
    out <- ""
    msg <- "No sub or ses pair was provided for updating the data."
    status <- 205
}else if(length(args) == 0){
    out <- ""
    msg <- "No key-value pair was provided for updating the data."
    status <- 202
}else if(length(error_col) != 0){
    out <- jsonlite::toJSON(error_col, pretty = TRUE)
    msg <- sprintf("'Process tags dont exist. Check spelling in: %s'",
        paste0(error_col, collapse = ",")
    )
    status <- 203
}else{
    err_vals <- list()
    for(i in 1:length(args)){
        value <- utils::URLdecode(unname(args[i]))
        key <- names(args)[i]
        ctype <- types[names(types) == key]
        val_ok <- FALSE
        if(ctype == "icons"){
            val_ok <- value %in% c("no", "yes", "running")
        }else if(ctype == "custom array"){
            val_ok <- value %in% proc[[key]]
        }else if(ctype == "numeric"){
            val_ok <- !is.na(as.numeric(value))
        }else if(ctype == "asis"){
            val_ok <- TRUE
        }
        if(val_ok){
            keypair <- list(value)
            names(keypair) <- key
            session <- list(keypair)
            names(session) <- ses
            # if sub & ses already exists in json
            if(!is.null(data[[sub]]) && !is.null(data[[sub]][[ses]])){
                data[[sub]][[ses]][[key]] <- value
            # if sub only exists and not session
            }else if(!is.null(data[[sub]])){
                data[[sub]] <- c(data[[sub]], session)
            #if sub does not exist
            }else{
                j <- length(data) + 1
                data[[j]] <- session
                names(data)[j] <- sub
            }
        }else{
            err_vals <- c(err_vals, args[i])
        }
    }
    if(length(err_vals) > 0){
        out <- jsonlite::toJSON(err_vals,
            pretty = TRUE)
        status <- 204
        msg <- "Some values do not correspond to values for the given process."
    }else{
        data <- sort_data(data)
        jsonlite::write_json(
            data, file.path(datadir, "data.json"),
            pretty = TRUE, auto_unbox = TRUE
        )
        entry <- list(data[[sub]][ses])
        names(entry) <- sub
        out <- jsonlite::toJSON(entry,
                pretty = TRUE, auto_unbox = TRUE)
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
