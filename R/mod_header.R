#' header UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_header_ui <- function(id){
  ns <- NS(id)
  tagList(
    titlePanel("grimeNet")
  )
}
    
#' header Server Function
#'
#' @noRd 
mod_header_server <- function(input, output, session){
  ns <- session$ns
 
}
    
## To be copied in the UI
# mod_header_ui("header_ui_1")
    
## To be copied in the server
# callModule(mod_header_server, "header_ui_1")
 
