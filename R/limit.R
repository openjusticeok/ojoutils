#' @title Limit
#'
#' @description A thin wrapper around \code{\link[utils]{head}} to sooth the pain of context switching between R and SQL 
#'
#' @details
#' A thin wrapper around \code{\link[utils]{head}} that allows
#' \code{limit} to be used in place of \code{head}. This is useful because
#' sometimes it is hard to context switch between R and SQL. It can be used on lazy data frames since
#' this package imports \code{dbplyr}.
#' 
#' @export 
#'
#' @param x The object to limit
#' @param ... Additional arguments to \code{\link[utils]{head}}
#' 
#' @return The limited object
#'
limit <- utils::head