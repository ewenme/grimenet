#' network UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_network_ui <- function(id){
  ns <- NS(id)
  tagList(
    visNetworkOutput(ns("network"), width = "100%", height = "100vh")
  )
}
    
#' network Server Function
#'
#' @noRd 
mod_network_server <- function(input, output, session, react_global){
  ns <- session$ns
  
  # create igraph network data
  network_data <- reactive({
    
    req(react_global$artist_years_data, react_global$artist_id)
    
    data <- toVisNetworkData(react_global$artist_years_data())
    
    # only label selected artists
    data$nodes$label <- if_else(
      data$nodes$node_id %in% react_global$artist_id,
      data$nodes$name_clean, ""
    )
    
    # add tooltip
    data$nodes$title <- map_chr(data$nodes$id, function(x) {
      
      relation_text <- map2_chr(react_global$artist_name, react_global$artist_name_clean, function(y, z) {
        
        if (x == y) return("")
        
        edges <- dplyr::filter(
          data$edges, from %in% c(x, y), to %in% c(x, y)
        )
        
        if (nrow(edges) == 0) return("")
        
        release_links <- map2_chr(
          edges$uri, edges$release_title_short, ~
            glue('<a target="_blank" href="https://www.discogs.com{.x}">{.y}</a>')
        )
        
        paste0(
          "Appeared with ", z, " on ", 
          glue_collapse(unique(release_links), sep = ", ", last = " and "),
          "."
        )
      })
      
      relation_text <- paste(relation_text[relation_text != ""], collapse = "<br>")
      
      paste("<p><b>", x, "</b><br>", relation_text, "</p>")      
      
    })
    data
  })
  
  # plot visNetwork
  output$network <- renderVisNetwork({
    
    visNetwork(network_data()$nodes, network_data()$edges) %>% 
      visIgraphLayout(
        layout = react_global$layout, type = "full", physics = TRUE
        ) %>% 
      visPhysics(solver = "repulsion") %>% 
      visInteraction(
        hideEdgesOnDrag = TRUE, 
        hoverConnectedEdges = FALSE,
        tooltipStyle = "
        position: fixed;
        visibility: hidden;
        padding: 5px;
        white-space: normal;
        
        font-family: 'Recursive', monospace;
        font-size: 14px;
        color: #000000;
        background-color: #f5f4ed;
        
        -moz-border-radius: 3px;
        -webkit-border-radius: 3px;
        border-radius: 3px;
        border: 1px solid #808074;
        
        "
        ) %>% 
      visNodes(
        shape = "circularImage", image = "",
        brokenImage = "https://img.discogs.com/HW8alHeuJdJbF_cd5MWdLf0QOhk=/100x100/filters:strip_icc():format(jpeg):quality(40)/discogs-avatars/U-1198484-1521139063.png.jpg",
        borderWidth = 4, borderWidthSelected = 6,
        color = list(
          border = "#000"
          ),
        font = list(
          color = "#fff", size = 24, face = "Recursive",
          strokeWidth = 5, strokeColor = "#000"
        )
        ) %>% 
      visEdges(
        color = list(
          color = "#b2bec3",
          highlight = "#636e72",
          opacity = 0.6
        ) 
      )
  })
  
}
    
## To be copied in the UI
# mod_network_ui("network_ui_1")
    
## To be copied in the server
# callModule(mod_network_server, "network_ui_1")
 
