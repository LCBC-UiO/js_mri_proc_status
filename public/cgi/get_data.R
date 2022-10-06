#!/usr/bin/env Rscript
source("utils.R")
datadir <- Sys.getenv("DATADIR")

args <- get_args()
subject <- sprintf("sub-%s", args[["sub"]])
session <- sprintf("ses-%s", args[["ses"]])
output <- "json"
if("out" %in% names(args)){
    output <- match.arg(args[["out"]], c("json", "single"))
}


data <- jsonlite::read_json(file.path(datadir, "data.json"))
tasks <- names(jsonlite::read_json(file.path(datadir, "tasks.json")))
tasks <- tasks[tasks %in% names(args)]
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
    out <- data
}else if(all(c("sub", "ses", "key") %in% names(args))){
    ses <- sub[[session]]
    keys <- lapply(match(args[["key"]], names(ses)), function(x) ses[[x]])
    names(keys) <- args[["key"]]
    out <- list(list(keys))
    names(out[[1]]) <- session
    names(out) <- subject
}else if(all(c("sub", "ses") %in% names(args))){
    out <- list(sub[session])
    names(out) <- subject
}else if("sub" %in% names(args)){
    out <- sub
}else{
    status <- 201
}

if(length(tasks))

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
