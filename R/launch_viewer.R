#' Start the nwmViewer shiny interface
#'
#' @keywords GUI
#' @export
#' @examples
#' # launch_viewer()

launch_viewer <- function(){
  shiny::runApp(appDir = system.file("nwmViewer", package = "nwmViewer"))
}
