#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  
  react_global <- reactiveValues(
    artist_id = NULL,
    artist_name = NULL,
    artist_data = NULL,
    artist_years_data = NULL,
    layout = "layout_nicely"
  )
  
  callModule(mod_about_server, "about_ui_1")
  callModule(
    mod_selections_server, "selections_ui_1", react_global
    )
  callModule(mod_network_server, "network_ui_1", react_global)
  
  waiter_hide()
}