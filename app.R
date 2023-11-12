# Il s'agit d'une application web Shiny. 
# Vous pouvez exécuter l'application en cliquant sur le bouton 'Run App' ci-dessus.

source("install.R") # Permet l'installation des packages

library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(readr)
library(shinyjs)

prepa <- source("prepa.R") # Récupération du dictionnaire servers_countries de prepa.R

repertoire <- dirname(rstudioapi::getSourceEditorContext()$path)
seasons <- character(0) # Regroupe toutes des années de saison
seasons_int <- integer(0) # Pour le slider (graph 1)

teams <- unique(unlist(lapply(seasons, function(season) data[[season]]$team_name))) # Pour la liste déroulante dynamique

# Recupération des saisons disponibles en fonction des fichiers csv présents
for (fichier in list.files(file.path(repertoire, "data"), pattern = "^season_.*\\.csv$")) {
  annee <- strsplit(strsplit(fichier, "_")[[1]][2], "\\.")[[1]][1]
  seasons_int <- c(seasons_int, as.integer(annee))
  seasons <- c(seasons, as.numeric(annee))
}

data <- list() # Dictionnaire : pour stocker les données de chaque saison, via les fichiers csv des saisons
for (season in seasons) {
  #df <- read.csv(file.path(repertoire, "data", paste0('season_', season, '.csv')), encoding = 'ISO-8859-1', sep = ';', stringsAsFactors = FALSE)
  df <- read.csv(file.path(repertoire, "data", paste0('season_', season, '.csv')), 
                 encoding = 'ISO-8859-1', 
                 sep = ';', 
                 stringsAsFactors = FALSE,
                 na.strings = c("-", "N/A", "NaN", ""))
  colnames(df) <- gsub('name', 'team_name', colnames(df))
  df$winRate <- as.numeric(gsub('%', '', df$winRate))
  data[[season]] <- df
}



ranged <- list( # Range : pour la colorimétrie des données consultés sur le dashboard + intervalle
  nbGames = c(0, NA,20),
  winRate = c(0, 100,10),
  KD = c(0, 2,0.2),
  GPM = c(1000, 2000,100),
  killsPerGame = c(0, 30,1),
  deathsPerGame = c(0, 30,1),
  towersKilled = c(0, 11,1),
  towersLost = c(0, 11,1)
)

# EXCEPTION : Pays dont l'iso2 ne correspond pas au iso/abrev du dictionnaire (servers_countries) crée dans prepa.py
LE <- c('WC', 'CIS', 'UK', 'PCS', 'SWE', 'CZ/SK')  # Liste des exceptions
E <- list(
  WC = list(except = 'RU'),
  CIS = list(except = 'RU'),
  UK = list(except = 'GB'),
  PCS = list(except = 'TW'),
  SWE = list(except = 'FI'),
  'CZ/SK' = list(except = 'CZ')
)

generate_histogram <- function(selected_season, selected_info) {
  req(selected_info) # S'assurer qu'une info est sélectionnée
  req(selected_season)  # S'assurer qu'une saison est sélectionnée

  season_data <- data[[as.character(selected_season)]]

  season_data[[as.character(selected_info)]] <- as.numeric(gsub("%", "", season_data[[as.character(selected_info)]]))
 

  range_values <- ranged[[as.character(selected_info)]]
  maxi <- range_values[2]  # Deuxième élément pour le max
  mini <- range_values[1]  # Premier élément pour le min

  # Si maxi est NA, attribuer le max de la colonne selected_info de season_data
  if (is.na(maxi)) {
    maxi <- max(season_data[[as.character(selected_info)]], na.rm = TRUE)
  }
  b<-range_values[3] # Intervalle pour l'histogramme
  
  plot <- ggplot(season_data, aes(x = cut(.data[[selected_info]], breaks = seq(mini, maxi, by = as.numeric(b)), right = FALSE))) +
    geom_bar() +
    labs(title = paste( selected_info,"des équipes - Season", selected_season),
         x = selected_info,
         y = "Count") +
    scale_x_discrete(labels = seq(mini, maxi, by = as.numeric(b)))
  return(plot)
}

generate_map_team <- function(selected_season, selected_info, selected_team) {
  req(selected_season)
  req(selected_info)
  req(selected_team)
  
  selected_season <- as.character(selected_season)
  selected_info <- as.character(selected_info)
  selected_team <- as.character(selected_team)
  
  df <- data[[selected_season]][c('region', selected_info, 'team_name')]
  df <- df[df$team_name == selected_team, ]  # Récupérer le dataframe associé à la saison et à l'équipe sélectionnées
  
  if (nrow(df) == 0) {  # Vérifier si le DataFrame est vide 
    error_message <- paste("Aucune information disponible pour", selected_info, "de l'équipe", selected_team, "dans la saison", selected_season, ".")
    fig <- plot_ly() %>%
    layout(title = error_message,
    showlegend = FALSE)
  } else {
    iso <- df$region[1]
    c <- vector("character", length = 0)
    v <- vector("numeric", length = 0)
    t <- vector("character", length = 0)
    
    if (as.character(iso) %in% names(prepa$value)) {  # Vérifier si l'iso est dans les clés du dictionnaire issu de prepa.R
      for (country in prepa$value[[as.character(iso)]]$countries) {
        c <- append(c, country)
        v <- append(v, df[[selected_info]][1])
        t <- append(t, selected_team)
      }
    } else {
      error_message <- paste("Aucune information disponible pour", selected_info, "de l'équipe", selected_team, "dans la saison", selected_season, ".")
      fig <- plot_ly() %>%
        layout(title = error_message,
               showlegend = FALSE)
    }
    
    df_map <- data.frame(country = c, value = v, team_name = t)  # Create the DataFrame for the map
    df_map <- df_map[complete.cases(df_map), ]  # Clean the data
    
    if (nrow(df_map) == 0) {  # DataFrame vide ?
      error_message <- paste("Aucune information disponible pour", selected_info, "de l'équipe", selected_team, "dans la saison", selected_season, ".")
      fig <- plot_ly() %>%
        layout(title = error_message,
               showlegend = FALSE)
    } else {
      
      # fig <- plot_ly( # Affichage carte choropleth
      #   df_map,
      #   type = 'choropleth', 
      #   locations = ~df_map$country,
      #   locationmode = 'country names',
      #   text = ~paste("Pays: ", df_map$country, "<br>Info: ", df_map$value, "<br>Équipe: ", df_map$team_name),
      #   z = ~value,
      #   colorscale = 'Rainbow',
      #   colorbar = list(title = selected_info)
      # )
      # 
      # fig <- fig %>%
      #   layout(
      #     geo = list(
      #       projection = list(type = 'natural earth'),
      #       showcoastlines = TRUE,
      #       coastlinecolor = toRGB("black"),
      #       showland = TRUE,
      #       landcolor = toRGB("lightgray"),
      #       showocean = TRUE,
      #       oceancolor = toRGB("lightblue"),
      #       showframe = FALSE,
      #       showcountries = TRUE,
      #       countrycolor = toRGB("black")
      #     )
      #   )
      fig <- plot_ly(
        df_map,
        type = 'choropleth', 
        locations = ~country,
        locationmode = 'country names',
        text = ~paste("Pays: ", df_map$country, "<br>Info: ", df_map$value, "<br>Équipe: ", df_map$team_name),
        z = ~value,
        colorscale = 'Rainbow',
        colorbar = list(title = selected_info)
      ) %>% layout(
        geo = list(
          projection = list(type = 'natural earth'),
          showcoastlines = TRUE,
          coastlinecolor = toRGB("black"),
          showland = TRUE,
          landcolor = toRGB("lightgray"),
          showocean = TRUE,
          oceancolor = toRGB("lightblue"),
          showframe = FALSE,
          showcountries = TRUE,
          countrycolor = toRGB("black")
        )
      )
      
      
      return(fig)
    }
  }
}

generate_map <- function(selected_season, selected_info) {
  req(selected_season)
  req(selected_info)
  df <- data[[selected_season]][c('region', selected_info, 'team_name')]

  c <- vector("character", length = 0)
  v <- vector("numeric", length = 0)
  
  # Vérifie que les colonnes existent dans le dataframe
  if (selected_info %in% colnames(df) && 'region' %in% colnames(df)) {
    for (i in 1:nrow(df)) {
      info <- df[i, selected_info]
      iso <- df[i, 'region']
      if (as.character(iso) %in% names(prepa$value)) {

        for (country in prepa$value[[as.character(iso)]]$countries) {

          c <- append(c, country)
          v <- append(v, info)
        }
      }
    }
  } else {
    # Gère le cas où les colonnes ne sont pas présentes dans le dataframe
    cat("Les colonnes spécifiées ne sont pas présentes dans le dataframe.\n")
  }
  
  df_map <- data.frame(country = c, value = v)
  df_map <- aggregate(value ~ country, data = df_map, FUN = ifelse(selected_info == "nbGames", sum, mean))
  
  # fig <- plot_ly( # Affichage de la carte choropleth
  #   df_map,
  #   type = 'choropleth',
  #   locations = ~country,
  #   locationmode = 'country names',
  #   z = ~value,
  #   colorscale = 'Viridis',
  #   colorbar = list(title = selected_info)
  # )
  # 
  # fig <- fig %>%
  #   layout(
  #     geo = list(
  #       projection = list(type = 'natural earth'),
  #       showcoastlines = TRUE,
  #       coastlinecolor = toRGB("black"),
  #       showland = TRUE,
  #       landcolor = toRGB("lightgray"),
  #       showocean = TRUE,
  #       oceancolor = toRGB("lightblue"),
  #       showframe = FALSE,
  #       showcountries = TRUE,
  #       countrycolor = toRGB("black")
  #     )
  #   )
  fig <- plot_ly(
    df_map,
    type = 'choropleth',
    locations = ~country,
    locationmode = 'country names',
    z = ~value,
    colorscale = 'Viridis',
    colorbar = list(title = selected_info)
  ) %>% layout(
    geo = list(
      projection = list(type = 'natural earth'),
      showcoastlines = TRUE,
      coastlinecolor = toRGB("black"),
      showland = TRUE,
      landcolor = toRGB("lightgray"),
      showocean = TRUE,
      oceancolor = toRGB("lightblue"),
      showframe = FALSE,
      showcountries = TRUE,
      countrycolor = toRGB("black")
    )
  )
  

  return(fig)
}

# Création de l'application Shiny
ui <- fluidPage(
  includeCSS("styles.css"),
  shinyjs::useShinyjs(),
  titlePanel(
    tags$h1("Projet League of Legends", style = "font-size: 40px; font-weight: bold; text-align: center;"),
    windowTitle = "LoL Projet"
  ),
  fluidRow(
    column(
      width = 6,
      tags$h1("Histogramme du Winrate en fonction de la Saison [ Seul graphique indépendant des autres ]", style = "text-align: center; color: #333; font-size: 24px; font-weight: bold;"),
      tags$h2("Sélectionne une saison, correspondant à une année :", style = "color: #666; font-size: 18px; font-weight: normal;"),
      sliderInput("year_slider", "Saison :",
                  min = if(length(seasons_int) > 0) min(as.integer(seasons_int)) else 0,
                  max = if(length(seasons_int) > 0) max(as.integer(seasons_int)) else 1,
                  value = if(length(seasons_int) > 0) max(as.integer(seasons_int)) else 1,
                  step = 1,
                  sep = ""),
      
      plotOutput("graph_content_1")
    ),
    column(
      width = 6,
      tags$h1("Carte du Monde en fonction de la Saison, dépendant de la caractéristique choisie", style = "text-align: center; color: #333; font-size: 24px; font-weight: bold;"),
      tags$h2("Sélectionne une saison, correspondant à une année :", style = "color: #666; font-size: 18px; font-weight: normal;"),
      selectInput("dropdown_selection", "Saison :", choices = seasons, selected = seasons[1]),
      tags$h2("Sélectionne une caractéristique à visualiser :", style = "color: #666; font-size: 18px; font-weight: normal;"),
      selectInput("dropdown_selection_2", "Caractéristique :", choices = c('nbGames', 'winRate', 'KD', 'GPM', 'killsPerGame', 'deathsPerGame', 'towersKilled', 'towersLost'), selected = 'nbGames'),
      #plotOutput("graph_content_2"),
      plotlyOutput("graph_content_2"),
      tags$h2("On peut voir que le jeu League of Legends n'est pas implanté dans tout le monde.", style = "color: #666; font-size: 18px; font-weight: normal;")
    )
  ),
  fluidRow(
    column(
      width = 6,
      tags$h1("Carte du Monde en fonction de la Saison des Teams, dépendant de la caractéristique choisie", style = "text-align: center; color: #333; font-size: 24px; font-weight: bold;"),
      tags$h2("Sélectionne une Team participant à la Saison choisie :", style = "color: #666; font-size: 18px; font-weight: normal;"),
      selectInput("dropdown_selection_3", "Team :", choices = teams, selected = teams[1]),
      #plotOutput("graph_content_3")
      plotlyOutput("graph_content_3"),
    ),
    column(
      width = 6,
      tags$h1("Histogramme en fonction de la saison, dépendant de la caractéristique choisie", style = "text-align: center; color: #333; font-size: 24px; font-weight: bold;"),
      plotOutput("graph_content_4")
    )
  )
)

server <- function(input, output, session) {
  
  observe({
    shinyjs::runjs("document.body.classList.add('dark-mode');")
  })
  
  # Met à jour le dropdown des teams en fonction de la saison sélectionnée
  observeEvent(input$dropdown_selection, {
    selected_season <- input$dropdown_selection
    teams <- unique(unlist(lapply(selected_season, function(season) data[[season]]$team_name)))
    updateSelectInput(session, "dropdown_selection_3", choices = teams, selected = teams[1])
  })
  
  # Histogramme du winrate
  output$graph_content_1 <- renderPlot({ 
    req(input$year_slider)  # S'assurer qu'une saison est sélectionnée
    season_data <- data[[as.character(input$year_slider)]]
    
    # Convertir la colonne winRate en type numérique
    season_data$winRate <- as.numeric(gsub("%", "", season_data$winRate))
    
    ggplot(season_data, aes(x = cut(winRate, breaks = seq(0, 100, by = 5), right = FALSE))) +
      geom_bar() +
      labs(title = paste("Winrate Histogram - Season", input$year_slider),
           x = "Winrate",
           y = "Frequency") +
      scale_x_discrete(labels = seq(0, 95, by = 5))
  })
  
  # Fonction réactive pour la carte du monde en fonction des saisons
  output$graph_content_2 <- renderPlotly({
    generate_map(as.character(input$dropdown_selection), as.character(input$dropdown_selection_2))
  })
  
  # Fonction réactive pour la carte des équipes
  output$graph_content_3 <- renderPlotly({
    generate_map_team(as.character(input$dropdown_selection), as.character(input$dropdown_selection_2), as.character(input$dropdown_selection_3))
  })
  
  # Fonction réactive pour l'histogramme en fonction de la saison et des différentes infos
  output$graph_content_4 <- renderPlot({
    generate_histogram(input$dropdown_selection, input$dropdown_selection_2)
  })
}

shinyApp(ui = ui, server = server)