#' about UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_about_ui <- function(id){
  ns <- NS(id)
  tagList(
    fixedPanel(
      top = 10, right = 10,
      circleButton(ns("about"), icon = icon("question-circle"), 
                   size = "sm")
    )
  )
}
    
#' about Server Function
#'
#' @noRd 
mod_about_server <- function(input, output, session){
  ns <- session$ns
 
  observeEvent(input$about, {
    showModal(modalDialog(
      title = NULL,
      includeMarkdown(app_sys('app/text/about.md'))
    ))
  })
}
    
## To be copied in the UI
# mod_about_ui("about_ui_1")
    
## To be copied in the server
# callModule(mod_about_server, "about_ui_1")
 
