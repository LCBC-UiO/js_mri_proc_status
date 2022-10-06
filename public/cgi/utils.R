tojson <- function(data){
    jsonlite::toJSON(data, pretty = TRUE, auto_unbox = TRUE)
}

calc_status <- function(data, sub, ses, type, status, sums){
    sub <- data[[sprintf("sub-%s", sub)]]
    ses <- sub[[sprintf("ses-%s", ses)]]
    tmp <- ses[grep(type, names(ses))]
    tmp <- tmp[grep("comment", names(tmp), invert = TRUE)]
    if(length(tmp) == 0) return("unknown")
    if(!type %in% sums) return(unlist(tmp))
    names(status) <- status
    k <- lapply(status, function(x){ sum(grepl(x, unlist(tmp)))})
    names(k) <- status
    k
}

get_args <- function(){
    args <- commandArgs(trailingOnly = TRUE)
    args <- gsub("^=", "", args)
    args <- unlist(strsplit(args, "\\&"))
    tmp <- lapply(args, function(x) 
                    gsub("sub-|ses-", "",
                    strsplit(x, "=")[[1]][-1])
                )
    names(tmp) <- sapply(args, function(x) strsplit(x, "=")[[1]][1])
    na.omit(tmp)
}

filter_data <- function(data, args, tasks){
    data <- lapply(data, function(sub) {
        sub <- lapply(sub, function(ses){
            idx <- which(tasks %in% names(ses))
            k <- logical()
            if(length(idx) == 0) k <- FALSE
            k <- all(k, sapply(idx, function(i){
                ses[tasks[i]] == args[[tasks[i]]]
            }))
            if(k) return(ses)
            return(NULL)
        })
        lapply(which(!sapply(sub, is.null)),
            function(ses) sub[[ses]])
    }) 
    idx <- sapply(data, function(x) length(x) > 0 ) 
    lapply(which(idx), function(x) data[[x]])
}
