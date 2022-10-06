#!/usr/bin/env Rscript
source("utils.R")
args <- get_args()

datadir <- Sys.getenv("DATADIR")
data <- jsonlite::read_json(file.path(datadir, "data.json"))
process <- jsonlite::read_json(file.path(datadir, "process.json"))
types <- names(process)
sums <- names(process[process == "sum"])
output <- "json"
idx <- grepl("output", names(args))
if(all(length(args) > 0, any(idx))){
    output <- match.arg(args[[which(idx)]], c("json", "table"))
}
stat <- c("ok", "fail", "rerun")
idx <- which(names(args) %in% "status")
if(length(idx) > 0){
    stat <- sapply(idx, function(x) match.arg(args[[x]], stat, several.ok = TRUE))
}

sub <- gsub("sub-", "", args["sub"]) #making sure prefix is not present
ses <- unlist(args[grepl("ses", names(args))])
keys <- unlist(args[grepl("key", names(args))])
run_all <- TRUE
if(length(ses) == 0 & sub != "NULL"){
    ses <- names(data[[sprintf("sub-%s", sub)]])
    run_all <- FALSE
}
if(length(ses) != 0) run_all <- FALSE

if(length(keys) == 0) keys <- types
keys <- match.arg(keys, types, several.ok = TRUE)
ses <- gsub("ses-", "", ses) #making sure prefix is not present

status <- 201
out <- list()

# If no subject specified, return all
if(run_all){
    subjects <- gsub("sub-", "", names(data))
    for(subject in subjects){
        sub <- data[[sprintf("sub-%s", subject)]]
        for(session in gsub("ses-", "", names(sub))){
            checks <- lapply(keys, function(x){
                calc_status(data = data,
                            sub = subject,
                            ses = session,
                            type = x,
                            status = stat,
                            sums = sums)
            })
            names(checks) <- keys
            sub[[sprintf("ses-%s", session)]] <- checks
        }
        out <- c(out, list(sub))
    }
    names(out) <- sprintf("sub-%s", subjects)
    status <- 200
}else if(length(ses) != 0){
    tmp <- list()
    for(session in ses){
        checks <- lapply(keys, function(x){
            calc_status(data = data,
                        sub = sub,
                        ses = session,
                        type = x,
                        status = stat,
                        sums = sums)
        })
        names(checks) <- keys
        tmp[[sprintf("ses-%s", session)]] <- checks
    }
    out <- list(tmp)
    names(out) <- sprintf("sub-%s", sub)
    status <- 200
}

if(output == "table"){
    tout <- lapply(1:length(out), function(x){
        tmp <- lapply(out[[x]], function(y) 
                    lapply(y, function(j) 
                        if(is.list(j)){ as.character(j) }else{ j }
                    )
                )
        tmp <- lapply(1:length(tmp), function(y){
            cbind(ses = names(tmp)[y],
                  status = stat, 
                  do.call(cbind, tmp[[y]]))
        })
        cbind(sub = names(out)[x],
              do.call(rbind, tmp))
    })
    tout <- do.call("rbind", tout)
    tout <- as.data.frame(tout, row.names = FALSE)
    tout <- tout[order(tout$sub, tout$ses),]

    tout <- c(
        paste0(names(tout), collapse = "\t"),
        apply(tout, 1, function(x) paste0(x, collapse = "\t"))
    )
    cat(
        "Content-Type: text/tab-separated-values'; charset=UTF-8\r",
        sprintf("Status: %s\r", status),
        sprintf("\r"),
        tout,
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
