#' selections UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_selections_ui <- function(id){
  ns <- NS(id)
  tagList(
    fixedPanel(
      top = 100, left = 10,
      actionButton(
        ns('toggle_selections'), label = 'Hide panel',
        style="opacity: .80; color: #fff; background-color: #a662e3; border-color: #a153e5"
        )
    ),
    absolutePanel(
      id = ns("selections"), top = 150, left = 10,
      pickerInput(
        ns("artist"), label = paste("choose artist(s)", intToUtf8(0x0001F465)),
        choices = setNames(grimenet::artists$artist_id, grimenet::artists$name_clean), 
        multiple = TRUE,
        options = pickerOptions(
          liveSearch = TRUE,
          liveSearchNormalize = TRUE,
          liveSearchPlaceholder = "search for an artist...",
          maxOptions = 5,
          size = 10
        )
      ),
      conditionalPanel(
        condition = paste0("input['", ns("artist"), "'] != '' "),
        chooseSliderSkin("Modern", color = "LightSlateGrey"),
        uiOutput(ns("get_year")),
        awesomeCheckboxGroup(
          ns("role"), label = paste("collaboration type", intToUtf8(0x0001F91D)), status = "info",
          choices = c(`feature/vocals`="feat|vocal", production="prod"),
          selected = c(`feature/vocals`="feat|vocal", production="prod"), 
          inline = TRUE
        ),
        pickerInput(
          ns("layout"), label = paste("play with the layout", intToUtf8(0x0001F4D0)),
          choices = c(
            star = "layout_as_star", tree = "layout_as_tree", 
            circle = "layout_in_circle", nicely = "layout_nicely", grid = "layout_on_grid", 
            sphere = "layout_on_sphere", randomly = "layout_randomly", dh = "layout_with_dh", 
            fr = "layout_with_fr", gem = "layout_with_gem", graphopt = "layout_with_graphopt", 
            kk = "layout_with_kk", lgl = "layout_with_lgl", mds = "layout_with_mds", 
            sugiyama = "layout_with_sugiyama"
          ), selected = "layout_nicely"
        ),
        actionButton(ns("reset"), label = "clear selections")
      )
    )
  )
}
    
#' selections Server Function
#'
#' @noRd 
mod_selections_server <- function(input, output, session, react_global){
  ns <- session$ns
  
  # toggle selections panel
  observeEvent(input$toggle_selections, {

    if(input$toggle_selections %% 2 == 1){
      shinyjs::hide(id = "selections")
      updateActionButton(session, "toggle_selections", label = "Show panel")
    }else{
      shinyjs::show(id = "selections")
      updateActionButton(session, "toggle_selections", label = "Hide panel")
    }
  })
  
  # get selected artist meta
  observeEvent(input$artist, {
    
    artist <- as.numeric(input$artist)
    
    react_global$artist_id <- grimenet::artists$node_id[grimenet::artists$artist_id %in% artist]
    react_global$artist_name <- grimenet::artists$name[grimenet::artists$artist_id %in% artist]
    react_global$artist_name_clean <- grimenet::artists$name_clean[grimenet::artists$artist_id %in% artist]
  })
  
  # update year range
  output$get_year <- renderUI({
    
    req(react_global$artist_data)
    
    years <- react_global$artist_data() %>% 
      activate(edges) %>% 
      pull(year)
    
    min_year <- min(years)
    max_year <- max(years)
    
    sliderInput(
      ns("year"), label = paste("choose time period", intToUtf8(0x0001F4C5)),
      min = min_year, max = max_year,
      value = c(min_year, max_year),
      step = 1, sep = ""
    )
  })
  
  # edit network layout
  observeEvent(input$layout, {
    react_global$layout <- input$layout
  })
  
  # keep selected artist data and adjacent nodes
  react_global$artist_data <- reactive({
    
    req(react_global$artist_id)
    
    grimenet::relations %>% 
      dplyr::filter(node_is_adjacent(react_global$artist_id, include_to = TRUE))
    
  })
  
  # filter artist data for years selection
  react_global$artist_years_data <- reactive({

    req(react_global$artist_data, react_global$artist_id, input$year)
    
    grimenet::relations %>%
      activate(edges) %>%
      dplyr::filter(
        between(year, input$year[1], input$year[2]),
        grepl(paste(input$role, collapse = "|"), extra_artist_role, ignore.case = TRUE)
        ) %>%
      activate(nodes) %>%
      dplyr::filter(node_is_adjacent(react_global$artist_id, include_to = TRUE))
    
  })
  
  # reset inputs
  observeEvent(input$reset, {
    updatePickerInput(session, "artist", selected = "")
    updateAwesomeCheckboxGroup(
      session, "role",
      selected = c(`feature/vocals`="feat|vocal", production="prod")
      )
    updatePickerInput(session, "layout", selected = "layout_nicely")
    
  })
}
    
## To be copied in the UI
# mod_selections_ui("selections_ui_1")
    
## To be copied in the server
# callModule(mod_selections_server, "selections_ui_1")
 
