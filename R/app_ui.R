#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    fillPage(
      setBackgroundColor(color = "#F5F5F5"),
      padding = 20,
      mod_header_ui("header_ui_1"),
      mod_selections_ui("selections_ui_1"),
      mod_network_ui("network_ui_1"),
      mod_about_ui("about_ui_1"),
      waiter_show_on_load(html = spin_wobblebar(), color = "#F5F5F5")
    )
  )
}
#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
 
  tags$head(
    favicon(),
    waiter::use_waiter(include_js = FALSE),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'GRIMENET'
    ),
    tags$style("#network{height:100vh !important;}"),
    tags$meta(property="og:title", content="GRIMENET"),
    tags$meta(property="og:type", content="website"),
    tags$meta(property="og:url", content="https://apps.ewen.io/grimenet"),
    tags$meta(property="og:image", content="https://apps.ewen.io/grimenet/www/grimenet-square.png"),
    tags$meta(property="og:description", content="An app exploring social networks within UK Grime"),
    tags$meta(name="twitter:card", content="summary_large_image"),
    tags$meta(name="twitter:site", content="@ewen_"),
    tags$meta(name="twitter:title", content="GRIMENET"),
    tags$meta(name="twitter:description", content="An app exploring social networks within UK Grime"),
    tags$meta(name="twitter:image:src", content="https://apps.ewen.io/grimenet/www/grimenet.png")
  )
  
}
