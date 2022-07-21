#!/usr/bin/env Rscript

datadir <- Sys.getenv("DATADIR")

args <- commandArgs(trailingOnly = TRUE)
args <- gsub("^=", "", args)
args <- unlist(strsplit(args, "\\&"))
args <- setNames(
        sapply(args, function(x) 
                sapply(strsplit(x, "=")[[1]][2], strsplit, split = ",")),
        gsub("^sub-|^ses-", "", 
            sapply(args, function(x) strsplit(x, "=")[[1]][1]))
        )
args <- na.omit(args)

tojson <- function(data){
    jsonlite::toJSON(data, pretty = TRUE, auto_unbox = TRUE)
}

data <- datao <- jsonlite::read_json(file.path(datadir, "data.json"))
status <- 200
msg <- "success"

if(length(args) == 0){
    status <- 203
    msg <- "Deletion needs arguments for id, session (optional) and key (optional)."
    data <- ""
}else if(all(c("sub", "ses", "key") %in% names(args))){
    sub <- data[[sprintf("sub-%s", args["sub"])]]
    ses <- sub[[sprintf("ses-%s", args["ses"])]]
    kidx <- !names(ses) %in% args[["key"]]
    keys <- lapply(which(kidx), function(x) ses[[x]])
    names(keys) <- names(ses)[kidx]
    if(length(keys) == 0){
        sub[[sprintf("ses-%s", args["ses"])]] <- NULL
    }else{
        sub[[sprintf("ses-%s", args["ses"])]] <- keys
    }
    if(length(sub) == 0){
        data[[sprintf("sub-%s", args["sub"])]] <- NULL 
    }else{
        data[[sprintf("sub-%s", args["sub"])]] <- sub
    }
}else if(all(c("sub", "ses") %in% names(args))){
    sub <- data[[sprintf("sub-%s", args["sub"])]]
    kidx <- !names(sub) %in% sprintf("ses-%s", args["ses"])
    ses <- lapply(which(kidx), function(x) ses[[x]])
    names(ses) <- names(sub)[kidx]
    data[[sprintf("sub-%s", args["sub"])]] <- ses
    if(length(data[[sprintf("sub-%s", args["sub"])]]) == 0){
       data[[sprintf("sub-%s", args["sub"])]] <- NULL 
    }
}else if("sub" %in% names(args)){
    kidx <- !names(data) %in% sprintf("sub-%s", args["sub"])
    data <- lapply(which(kidx), function(x) data[[x]])
    names(data) <- names(datao)[kidx]
}else{
    status <- 201
}
if(status == 200){
    jsonlite::write_json(data, file.path(datadir, "data.json"), 
        pretty = TRUE, auto_unbox = TRUE )
}
cat(
    "Content-Type: application/json; charset=UTF-8\r",
    sprintf("Status: %s\r", status),
    sprintf("Message: %s\r", msg),
    sprintf("\r"),
    tojson(data),
    sep = "\n"
)
