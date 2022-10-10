#!/usr/bin/env Rscript
source("utils.R")

data <- read_json("data.json")

args <- get_args()
status <- 200
msg <- "success"
if(length(args) == 0){
    status <- 203
    msg <- "Deletion needs arguments for id, session (optional) and key (optional)."
    data <- ""
}else if(all(c("sub", "ses", "key") %in% names(args))){
    sub <- data[[args["sub"]]]
    ses <- sub[[args["ses"]]]
    kidx <- !names(ses) %in% args["key"]
    keys <- lapply(which(kidx), function(x) ses[[x]])
    names(keys) <- names(ses)[kidx]
    if(length(keys) == 0){
        sub[[args["ses"]]] <- NULL
    }else{
        sub[[args["ses"]]] <- keys
    }
    if(length(sub) == 0){
        data[[args["sub"]]] <- NULL 
    }else{
        data[[args["sub"]]] <- sub
    }
}else if(all(c("sub", "ses") %in% names(args))){
    sub <- data[[args["sub"]]]
    print(sub)
    kidx <- !names(sub) %in% args["ses"]
    ses <- lapply(which(kidx), function(x) sub[[x]])
    names(ses) <- names(sub)[kidx]
    data[[args["sub"]]] <- ses
    if(length(data[[args["sub"]]]) == 0){
       data[[args["sub"]]] <- NULL 
    }
}else if("sub" %in% names(args)){
    kidx <- !names(data) %in% args["sub"]
    data <- lapply(which(kidx), function(x) data[[x]])
    names(data) <- names(datao)[kidx]
}else{
    status <- 201
}
if(status == 200){
    write_json(data, "data.json")
}
cat(
    "Content-Type: application/json; charset=UTF-8\r",
    sprintf("Status: %s\r", status),
    sprintf("Message: %s\r", msg),
    sprintf("\r"),
    tojson(data),
    sep = "\n"
)
