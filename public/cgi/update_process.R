#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)
args <- unlist(strsplit(args, "\\&"))
args <- setNames(
        sapply(args, function(x) strsplit(x, "=")[[1]][2]),
        sapply(args, function(x) strsplit(x, "=")[[1]][1])
)

proc <- jsonlite::read_json("../json/process.json", simplifyVector = TRUE)
idx <- unique(na.omit(match(names(proc), names(args))))
if(length(idx) > 0){
    status <- 203
    msg <- "Some requested process keys already exist. Not updating process."
    out <- jsonlite::toJSON(names(args)[idx], pretty = TRUE)
}else if(any(! args %in% c("options", "numeric"))){
    idx <- which(any(! args %in% c("options", "numeric")))
    status <- 204
    msg <- "Some requested process value are neither 'numeric' nor 'options'. Not updating process."
    out <- jsonlite::toJSON(args[idx], pretty = TRUE)
}else{
    proc <- c(proc, as.list(args))
    status <- 201
    msg <- "Process updated"
    out <- jsonlite::toJSON(proc, pretty = TRUE, auto_unbox = TRUE)
    jsonlite::write_json(proc, 
        "../json/process.json", 
        pretty = TRUE, 
        auto_unbox = TRUE)
}
cat(
    "Content-Type: application/json; charset=UTF-8\r",
    sprintf("Status: %s\r", status),
    sprintf("Message : %s\r", msg),
    "\r",
    out,
    sep = "\n"
)