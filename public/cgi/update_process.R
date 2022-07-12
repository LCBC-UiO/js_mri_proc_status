#!/usr/bin/env Rscript
datadir <- Sys.getenv("DATADIR")

args <- commandArgs(trailingOnly=TRUE)
args <- unlist(strsplit(args, "\\&"))
args <- setNames(
        sapply(args, function(x) 
                sapply(strsplit(x, "=")[[1]][2], strsplit, split = ",")),
        sapply(args, function(x) strsplit(x, "=")[[1]][1])
        )
types <- sapply(args, function(x){
   if(length(x) > 1)
    return("array")
   unname(x)
})
valid_types <- c("icons", "numeric", "array", "asis")
proc <- jsonlite::read_json(file.path(datadir, "process.json"), simplifyVector = TRUE)
idx <- unique(na.omit(match(names(proc), names(args))))
if(length(idx) > 0){
    status <- 203
    msg <- "Some requested process keys already exist. Not updating process."
    out <- jsonlite::toJSON(names(args)[idx], pretty = TRUE)
}else if(any(! types %in% valid_types)){
    idx <- which(any(! types %in% valid_types))
    status <- 204
    msg <- sprintf("Some requested process value are none of %s. Not updating process.", paste(valid_types, collapse=", "))
    out <- jsonlite::toJSON(args[idx], pretty = TRUE)
}else{
    proc <- c(proc, as.list(args))
    status <- 201
    msg <- "Process updated"
    out <- jsonlite::toJSON(proc, pretty = TRUE, auto_unbox = TRUE)
    jsonlite::write_json(proc,
        file.path(datadir, "process.json"),
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