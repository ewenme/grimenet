golem::fill_desc(
  pkg_name = "grimenet",
  pkg_title = "grimenet",
  pkg_description = "Interactive web app for exploring grime music networks.",
  author_first_name = "Ewen",
  author_last_name = "Henderson",
  author_email = "ewenhenderson@gmail.com",
  repo_url = NULL
)     
golem::set_golem_options()
usethis::use_mit_license( name = "Ewen Henderson" )
usethis::use_readme_rmd( open = FALSE )
usethis::use_code_of_conduct()
usethis::use_lifecycle_badge( "Experimental" )
usethis::use_news_md( open = FALSE )
usethis::use_git()
golem::use_recommended_tests()
golem::use_recommended_deps()
golem::remove_favicon()
golem::use_favicon()
golem::use_utils_ui()
golem::use_utils_server()
rstudioapi::navigateToFile( "dev/02_dev.R" )
