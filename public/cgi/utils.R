options(stringsAsFactors = FALSE)
datadir <- Sys.getenv("DATADIR")

tojson <- function(data){
    jsonlite::toJSON(data, pretty = TRUE, auto_unbox = TRUE)
}

write_json <- function(data, file){
    jsonlite::write_json(
        x = data,
        path = file.path(datadir, file),
        pretty = TRUE,
        auto_unbox = TRUE
    )
}

read_json <- function(file){
    jsonlite::read_json(
        path = file.path(datadir, file),
        simplifyVector = TRUE
    )
}


calc_status <- function(data, sub, ses, type, status, sums){
    sub <- data[[sub]]
    ses <- sub[[ses]]
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
    if(any(is.null(args), length(args) == 0)) return(NULL)
    args <- utils::URLdecode(args)
    args <- unlist(strsplit(args, "\\&"))
    tmp <- lapply(args, function(x) 
                    gsub("sub-|ses-", "",
                    strsplit(x, "=")[[1]][-1])
                )
    names(tmp) <- sapply(args, function(x) strsplit(x, "=")[[1]][1])
    tmp <- na.omit(tmp)
    tmp <- tmp[which(sapply(tmp, function(x) length(x) > 0))]
    unlist(tmp)
}

filter_data <- function(data, args, tasks){
    data <- lapply(data, function(sub) {
        sub <- lapply(sub, function(ses){
            idx <- which(tasks %in% names(ses))
            k <- logical()
            if(length(idx) == 0) k <- FALSE
            k <- all(k, sapply(idx, function(i){
                ses[tasks[i]] == args[tasks[i]]
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

sort_data <- function(x, tasks){
    .name_order <- function(x) x[order(names(x))]
    x <- .name_order(x)
    x <- lapply(x, .name_order)
    lapply(x, function(y){
        lapply(y, function(p){
            p[na.omit(match(tasks, names(p)))]
        })
    })
}
