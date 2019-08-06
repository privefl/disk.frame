#' Make a data.frame into a disk.frame
#' @param df a disk.frame
#' @param outdir the output directory
#' @param nchunks number of chunks
#' @param overwrite if TRUE the outdir will be overwritten, if FALSE it will throw an error if the directory is not empty
#' @param compress the compression level 0-100; 100 is highest
#' @param shardby The shardkey
#' @param ... passed to output_disk.frame
#' @import fst
#' @importFrom data.table setDT
#' @export
#' @examples 
#' # write to temporary location
#' cars.df = as.disk.frame(cars) 
#' 
#' # clean up
#' delete(cars.df)
#' 
#' \dontrun{
#' # specify a different path
#' as.disk.frame(cars, outdir = "some_path.df") 
#' 
#' # specify a different number of chunks
#' as.disk.frame(cars, nchunks = 4, overwrite = TRUE) 
#' }
as.disk.frame <- function(df, outdir = tempfile(fileext = ".df"), nchunks = recommend_nchunks(df), overwrite = FALSE, shardby = NULL, compress = 50,...) {
  stopifnot("data.frame" %in% class(df))
  overwrite_check(outdir, overwrite)
  setDT(df)
  
  if (is.null(shardby)) {
    odfi = rep(1:nchunks, each = ceiling(nrow(df)/nchunks))
    odfi = odfi[1:nrow(df)]
    df[, .out.disk.frame.id := odfi]
    
    write_disk.frame(df, outdir, nchunks, overwrite = TRUE, shardby="", compress = compress, ...)
  } else {
    shard(df, shardby = shardby, outdir = outdir, nchunks = nchunks, overwrite = T, compress = compress, ...)
  }
}