#!/usr/bin/env Rscript
datadir <- Sys.getenv("DATADIR")

args <- commandArgs(trailingOnly = TRUE)
args <- unlist(strsplit(args, "\\&"))
args <- setNames(
        sapply(args, function(x) strsplit(x, "=")[[1]][2]),
        sapply(args, function(x) strsplit(x, "=")[[1]][1])
)
id   <- args[1]
ses  <- args[2]
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
# Return error code if any column requested does not match process
error_col <- names(args)[which(!names(args) %in% names(proc))]
if(length(error_col) != 0){
    out <- jsonlite::toJSON(error_col, pretty = TRUE)
    msg <- sprintf("'Process tags dont exist. Check spelling in: %s'",
        paste0(error_col, collapse = ",")
    )
    status <- 203
    type <- "text/plain"
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
            # if id & ses already exists in json
            if(!is.null(data[[id]]) && !is.null(data[[id]][[ses]])){
                data[[id]][[ses]][[key]] <- value
            # if id only exists and not session
            }else if(!is.null(data[[id]])){
                data[[id]] <- c(data[[id]], session)
            #if id does not exist
            }else{
                j <- length(data) + 1
                data[[j]] <- session
                names(data)[j] <- id
            }
        }else{
            err_vals <- c(err_vals, args[i])
        }
    }
    if(length(err_vals) > 0){
        out <- jsonlite::toJSON(err_vals,
            pretty = TRUE)
        status <- 204
        msg <- "Some values do not correspond to correct values for the given process."

    }else{
        data <- sort_data(data)
        jsonlite::write_json(
            data, file.path(datadir, "data.json"),
            pretty = TRUE, auto_unbox = TRUE
        )
        entry <- list(data[[id]][ses])
        names(entry) <- id
        out <- jsonlite::toJSON(entry,
                pretty = TRUE, auto_unbox = TRUE)
        status <- 201
        msg <- sprintf("Progress updated for %s %s", id, ses)
    }
}

cat(
    "Content-Type: application/json; charset=UTF-8\r",
    sprintf("Status: %s\r", status),
    sprintf("Message : %s\r", msg),
    "\r",
    out,
    sep = "\n"
)
