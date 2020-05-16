# unnest releases data
unnest_releases <- function(x) {
  
  releases <- unnest_longer(x, artists)
  
  artists <- mutate_all(releases$artists, unlist)
  
  releases <- releases %>% 
    select(-artists) %>% 
    bind_cols(artists) %>% 
    rename(release_title=title, release_title_short=title_short,
           artist_id=id, artist_name=name, artist_thumbnail_url=thumbnail_url) %>% 
    # remove various artist releases / releases no one owns
    dplyr::filter(artist_id != 194, community_have > 0) %>% 
    # keep most owner version of duplicates
    group_by(release_title, artist_id) %>% 
    dplyr::filter(community_have == max(community_have)) %>% 
    ungroup() %>% 
    # remove records w/o a year
    mutate(year=as.numeric(year)) %>% 
    dplyr::filter(!is.na(year))
  
  # remove mixes and compilations
  releases <- releases[map_lgl(releases$format, function(x) {
    
    !any(grepl("mixed|compilation", unlist(x), ignore.case = TRUE))
  }), ]
  
  releases
  
}

# unnest tracks data
unnest_tracks <- function(x) {
  
  tracklists <- unnest_longer(x, tracklist)
  
  tracks <- mutate_at(
    tracklists$tracklist, vars(-extraartists, -artists), unlist
  )
  tracklists_tidy <- tracklists %>% 
    select(-tracklist) %>% 
    bind_cols(tracks) %>% 
    mutate(release_id = unlist(release_id)) %>% 
    unnest_longer(extraartists)
  
  # add features to tracks
  features <- tracklists_tidy$extraartists
  features <- map(features, function(y) {
    
    y[sapply(y, is.null)] <- NA
    y
  })
  
  tracklists_tidy %>% 
    mutate(extra_artist_name = unlist(features$name),
           extra_artist_id = unlist(features$id),
           extra_artist_role = unlist(features$role),
           extra_artist_thumbnail = unlist(features$thumbnail_url)) %>% 
    select(-extraartists, -artists) %>% 
    rename(track_title=title) %>% 
    group_by(release_id, track_title) %>% 
    dplyr::filter(
      str_detect(
        extra_artist_role, 
        regex("feat|vocal|prod", ignore_case = TRUE))
    )
}

# unnest artists data
unnest_artists <- function(x) {
  
  x$aliases <- map(x$aliases, function(x) {
    
    if (!is.null(x)) transpose(x)
  })
  
  unnest_longer(x, aliases) %>% 
    hoist(aliases,
          alias_id = "id",
          alias_name = "name",
          alias_thumbnail_url = "thumbnail_url") %>% 
    select(
      artist_name = name,
      artist_id = id,
      alias_id, alias_name, alias_thumbnail_url
    ) %>% 
    unnest(c(artist_name, artist_id))
}

# merge data sources
merge_data_sources <- function(tracks, releases, artists) {
  
  releases <- tidy_releases
  tracks <- tidy_tracks
  artists <- tidy_artists
  
  # join tracks/releases
  releases_merged <- left_join(releases, tracks, by = "release_id")
  
  # identify if extra artists are aliases of main artist
  alias_matches <- map_lgl(1:nrow(releases_merged), function(x) {
    
    main_artist <- releases_merged$artist_id[x]
    extra_artist <- releases_merged$extra_artist_id[x]
    
    main_artist_aliases <- artists %>% 
      dplyr::filter(artist_id == main_artist) %>% 
      pull(alias_id)
    
    !extra_artist %in% c(main_artist, main_artist_aliases)
  })
  
  # remove aliases of main artist
  releases_merged <- releases_merged[alias_matches ,]
  
  # isolate releases w/o extra artists
  releases_no_extra <- releases_merged %>% 
    dplyr::filter(is.na(extra_artist_id)) %>% 
    group_by(release_id) %>% 
    expand(
      release_id, artist_id = artist_id, extra_artist_id = artist_id
    ) %>% 
    dplyr::filter(artist_id != extra_artist_id, artist_id == first(artist_id)) %>%
    ungroup() %>% 
    inner_join(
      select(releases_merged, -extra_artist_id, -extra_artist_name), 
      by = c("release_id", "artist_id")
    ) %>% 
    inner_join(
      select(releases_merged, release_id, artist_id, artist_name), 
      by = c("release_id", "extra_artist_id"="artist_id")
    ) %>% 
    rename(artist_name=artist_name.x, extra_artist_name=artist_name.y)
  
  releases_merged %>% 
    # remove releases w/o extra artist
    dplyr::filter(!is.na(extra_artist_id)) %>%
    distinct(release_id, artist_id, extra_artist_id, track_title,
             .keep_all = TRUE) %>% 
    bind_rows(releases_no_extra) %>%
    select(
      release_id, release_title_short, uri, track_title, 
      artist_id, artist_name, artist_thumbnail_url, 
      extra_artist_name:extra_artist_thumbnail, year,
      style, community_have, community_want
    ) %>% 
    # only artists that have made a straight grime record
    mutate(style = suppressWarnings(str_c(style))) %>%
    group_by(artist_id) %>% 
    dplyr::filter(any(style == "Grime")) %>% 
    ungroup()
  
}

