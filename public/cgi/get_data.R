#!/usr/bin/env Rscript

datadir <- Sys.getenv("DATADIR")

args <- commandArgs(trailingOnly = TRUE)
args <- gsub("^=", "", args)
args <- unlist(strsplit(args, "\\&"))
args <- setNames(
        sapply(args, function(x) 
                sapply(strsplit(x, "=")[[1]][2], strsplit, split = ",")),
        sapply(args, function(x) strsplit(x, "=")[[1]][1])
        )
args <- na.omit(args)

tojson <- function(data){
    jsonlite::toJSON(data, pretty = TRUE, auto_unbox = TRUE)
}

data <- jsonlite::read_json(file.path(datadir, "data.json"))
status <- 200
out <- ''
if(length(args) == 0){
    out <- data
}else if(all(c("sub", "ses", "key") %in% names(args))){
    sub <- data[[sprintf("sub-%s", args["sub"])]]
    ses <- sub[[sprintf("ses-%s", args["ses"])]]
    keys <- lapply(match(args[["key"]], names(ses)), function(x) ses[[x]])
    names(keys) <- args[["key"]]
    out <- list(list(keys))
    names(out[[1]]) <- sprintf("ses-%s", args["ses"])
    names(out) <- sprintf("sub-%s", args["sub"])
}else if(all(c("sub", "ses") %in% names(args))){
    sub <- data[[sprintf("sub-%s", args["sub"])]]
    out <- list(sub[sprintf("ses-%s", args["ses"])])
    names(out) <- sprintf("sub-%s", args["sub"])
}else if("sub" %in% names(args)){
    out <- data[sprintf("sub-%s", args["sub"])]
}else{
    status <- 201
}

cat(
    "Content-Type: application/json; charset=UTF-8\r",
    sprintf("Status: %s\r", status),
    sprintf("\r"),
    tojson(out),
    sep = "\n"
)
