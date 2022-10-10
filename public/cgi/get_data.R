#!/usr/bin/env Rscript
source("utils.R")
args <- get_args()

data <- read_json( "data.json")

subject <- args["sub"]
session <- args["ses"]
output <- "json"
if("output" %in% names(args)){
    output <- match.arg(args["output"], c("json", "single"))
}
tasks <- names(read_json( "tasks.json"))
tasks <- tasks[tasks %in% names(args)]
if(length(tasks) > 0)
    data <- filter_data(data, args, tasks)
status <- 200
out <- ''
sub <- NULL
if(length(subject) != 0){
    sub <- data[[subject]]
}

if(length(args) == 0){
    out <- data
}else if(is.null(sub)){
    status <- 202
}else if(all(c("sub", "ses", "key") %in% names(args))){
    ses <- sub[[session]]
    keys <- lapply(match(args["key"], names(ses)), function(x) ses[[x]])
    names(keys) <- args["key"]
    out <- list(list(keys))
    names(out[[1]]) <- session
    names(out) <- subject
}else if(all(c("sub", "ses") %in% names(args))){
    out <- list(sub[session])
    names(out) <- subject
}else if("sub" %in% names(args)){
    status <- 203
    out <- sub
}else{
    status <- 201
}

if(output == "single"){
    cat(
        "Content-Type: application/json; charset=UTF-8\r",
        sprintf("Status: %s\r", status),
        sprintf("\r"),
        tojson(out[[1]][[1]]),
        sep = "\n"
    )
}else{
    cat(
        "Content-Type: application/json; charset=UTF-8\r",
        sprintf("Status: %s\r", status),
        sprintf("\r"),
        tojson(out),
        sep = "\n"
    )
}
