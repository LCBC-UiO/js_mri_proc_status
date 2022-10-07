#!/usr/bin/env Rscript
source("utils.R")
datadir <- Sys.getenv("DATADIR")

args <- get_args()

for(key in c("sub", "ses", "project_id", "wave_code")){
    idx <- which(names(args) %in% key)
    if(length(idx) != 0){
        assign(key, gsub("sub-|ses-", "", args[idx]))
        args <- args[idx*-1]
    }
}

proc <- jsonlite::read_json(file.path(datadir, "protocol.json"),
    simplifyVector = TRUE)
proc <- proc[[project_id]][[wave_code]]

tasks <- jsonlite::read_json(file.path(datadir, "tasks.json"),
    simplifyVector = TRUE)
types <- sapply(proc, function(x){
   k <- tasks[[x]]$value
    if(!is.null(tasks[[x]]$comments) && tasks[[x]]$comments == "yes"){
        k <- c(k, setNames("asis", "comments"))
    }
   k
})
types <- unlist(types)
names(types) <- gsub("\\.", "_", names(types))
names(types) <- gsub("1$", "", names(types))
data <- jsonlite::read_json(file.path(datadir, "data.json"))
error_col <- names(args)[which(!names(args) %in% names(types))]
if(any(!c(exists("sub"), exists("ses")))){
    out <- ""
    msg <- "No 'sub' or 'ses' pair was provided for updating the data."
    status <- 205
}else if(any(!c(exists("project_id"), exists("wave_code")))){
    out <- ""
    msg <- "No 'project_id' or 'wave_code' pair was provided for updating the data."
    status <- 205
}else if(length(args) == 0){
    out <- ""
    msg <- "No key-value pairs were provided for updating the data."
    status <- 202
}else if(length(error_col) != 0){
    out <- jsonlite::toJSON(error_col, pretty = TRUE)
    msg <- sprintf("'Process tags dont exist. Check spelling in: %s'",
        paste0(error_col, collapse = ",")
    )
    status <- 203
}else{
    sub <- paste0("sub-", sub)
    ses <- paste0("ses-", ses)
    data[[sub]][[ses]]["project_id"] <- project_id
    data[[sub]][[ses]]["wave_code"] <- wave_code
    err_vals <- list()
    for(i in 1:length(args)){
        value <- utils::URLdecode(unname(args[i]))
        key <- names(args)[i]
        ctype <- unname(types[names(types) == key])
        val_ok <- FALSE
        if(ctype == "icons"){
            val_ok <- value %in% c("fail", "ok", "rerun")
        }else if(ctype == "numeric"){
            val_ok <- !is.na(as.numeric(value))
        }else if(ctype == "asis"){
            val_ok <- TRUE
        }else if(Array.isArray(ctype)){
            val_ok <- value %in% ctype
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
        data <- sort_data(data, names(types))
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
