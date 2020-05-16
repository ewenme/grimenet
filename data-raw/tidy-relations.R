library(jsonlite)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(tidygraph)

devtools::load_all()

# load data ---------------------------------------------------------------

releases <- read_json("../grime-archives/data/grime-releases.json", 
                      simplifyVector = TRUE)
tracks <- read_json("../grime-archives/data/grime-tracks.json", 
                    simplifyVector = TRUE)
artists <- read_json("../grime-archives/data/grime-artists.json", 
                     simplifyVector = TRUE)

# wrangle -----------------------------------------------------------------

# unnest nested objects
tidy_releases <- unnest_releases(releases)
tidy_tracks <- unnest_tracks(tracks)
tidy_artists <- unnest_artists(artists)

# merge data sources
tracks_merged <- merge_data_sources(
  tidy_tracks, tidy_releases, tidy_artists
  )

# get unique artists metadata
artists_meta <- tracks_merged %>% 
  select(artist_id:artist_thumbnail_url) %>% 
  bind_rows(
    select(tracks_merged, artist_id=extra_artist_id,
           artist_name=extra_artist_name, artist_thumbnail_url=extra_artist_thumbnail)
  ) %>% 
  distinct(artist_id, .keep_all=TRUE)

# create graph df
relations <- tracks_merged %>% 
  rename(from=artist_name, to=extra_artist_name) %>% 
  as_tbl_graph(directed = FALSE) %>% 
  distinct(name, .keep_all = TRUE) %>% 
  # calculate centrality/group metrics
  mutate(
    node_id = seq_along(name),
    component_group = group_components(),
    name_clean = str_trim(
      str_remove_all(name, pattern = "\\([^\\]]*\\)")
    ),
    n_records = centrality_degree(mode = "in"),
  ) %>% 
  left_join(artists_meta, by = c("name"="artist_name")) %>% 
  rename(image=artist_thumbnail_url)

artists <- as_tibble(relations) %>% 
  arrange(name)

# export ------------------------------------------------------------------

usethis::use_data(relations, artists, overwrite = TRUE)
