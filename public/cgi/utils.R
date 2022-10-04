tojson <- function(data){
    jsonlite::toJSON(data, pretty = TRUE, auto_unbox = TRUE)
}

calc_status <- function(data, sub, ses, type){
    sub <- data[[sprintf("sub-%s", sub)]]
    ses <- sub[[sprintf("ses-%s", ses)]]
    tmp <- ses[grep(type, names(ses))]
    tmp <- tmp[grep("comment", names(tmp), invert = TRUE)]
    if(length(tmp) == 0) return("unknown")
    if(!type %in% sums) return(unlist(tmp))
    sum(grepl("ok", unlist(tmp)))
}

get_args <- function(){
    args <- commandArgs(trailingOnly = TRUE)
    args <- gsub("^=", "", args)
    args <- unlist(strsplit(args, "\\&"))
    args <- setNames(
            sapply(args, function(x) 
                    sapply(strsplit(x, "=")[[1]][2], strsplit, split = ",")),
            sapply(args, function(x) strsplit(x, "=")[[1]][1])
            )
    na.omit(args)
}