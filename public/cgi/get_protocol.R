#!/usr/bin/env Rscript
source("utils.R")

proto <- read_json( "protocol.json")

args <- get_args()
out <- proto

output <- "json"
if("out" %in% names(args)){
    output <- match.arg(args["out"], c("json", "single"))
}

idx <- names(out) %in% unlist(args[grepl("proj", names(args))])
if(any(idx)) out <- out[idx]

out <- lapply(out, function(x){
    idx <- names(x) %in% unlist(args[grepl("wave", names(args))])
    if(any(idx)) x <- x[idx]
    x
})

if(any(grepl("unknown", unlist(args)))){
    out <- "{}"
}

status <- 200
if(output == "single"){
    cat(
        "Content-Type: application/json; charset=UTF-8\r",
        sprintf("Status: %s\r", status),
        sprintf("\r"),
        tojson(unlist(out)),
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