#' Create a shinymaterial page
#'
#' Build a shinymaterial page.
#' @param ... The UI elements to place in the page.
#' @param title String. The title of the page.
#' @param nav_bar_fixed Boolean. Should the nav bar remain fixed on the screen?
#' @param nav_bar_color Color of the nav bar. Leave blank for the default color. Visit \url{http://materializecss.com/color.html} for a list of available colors.
#' @param background_color Page background color. Leave blank for the default color. Visit \url{http://materializecss.com/color.html} for a list of available colors.
#' @param font_color String. The title font color. Leave blank for the default color. Visit \url{http://materializecss.com/color.html} for a list of available colors. \emph{Title color requires using word forms of colors (e.g. "deep-purple"). Also, lighten or darken effects do not work on title colors.}
#' @param include_fonts Boolean. Should the material font files be included? (This will place the font sources in a directory 'www', at the same location as the app code.)
#' @param include_nav_bar Boolean. Should the material nav bar be included?
#' @param include_icons Boolean. Should the material icon files be included? (This will place the font sources in a directory 'www', at the same location as the app code.)
#' @param materialize_in_www Boolean. Should the app look for the materialize library in the 'www' folder? E.g. www/css/materialize.min.css & www/js/materialize.min.js (Default to FALSE - which will look in the package library folder)
#' @examples
#' material_page(
#'   title = "Example Title",
#'   nav_bar_fixed = TRUE,
#'   nav_bar_color = "red lighten-2",
#'   background_color = "blue lighten-4",
#'   shiny::tags$h1("Page Content")
#' )
material_page <- function(..., title = "", nav_bar_fixed = FALSE, nav_bar_color = NULL, background_color = "grey lighten-4", font_color = NULL, include_fonts = FALSE, include_nav_bar = TRUE, include_icons = FALSE, materialize_in_www = FALSE){
  
  materialize_version <- "1.0.0"
  materialicons_version <- "v42"
  
  if(!materialize_in_www){
    css_location <- 
      system.file(
        paste0("materialize/", materialize_version, "/css/materialize.min.css"),
        package = "shinymaterial"
      )
    js_location <- 
      system.file(
        paste0("materialize/", materialize_version, "/js/materialize.min.js"),
        package = "shinymaterial"
      )
  } else {
    css_location <- "www/css/materialize.min.css"
    js_location <- "www/js/materialize.min.js"
  }
  
  if(include_fonts){
    
    dir_recursion <- c("www", "www/fonts", "www/fonts/roboto")
    
    for(dir.i in dir_recursion){
      if(!dir.exists(dir.i)){
        if(dir.i == "www/fonts/roboto"){
          message(
            paste0(
              "[shinymaterial] Creating directory: ",
              file.path(getwd(), dir.i)
            )
          )
        }
        dir.create(dir.i)
      }
    }
    
    font_files <- list.files(
      system.file(paste0("materialize/", materialize_version, "/fonts/roboto"),
                  package = "shinymaterial")
    )
    
    for(font_file.i in font_files){
      file.copy(
        from = system.file(paste0("materialize/", materialize_version, "/fonts/roboto/", font_file.i),
                           package = "shinymaterial"),
        to = paste0("www/fonts/roboto/", font_file.i),
        overwrite = TRUE
      )
    }
  }
  
  
  if(include_icons){
    icons_files <- list.files(
      system.file(file.path("icons", "materialicons", materialicons_version),
                  package = "shinymaterial"),
      full.names = TRUE
    )
    
    
    if (!dir.exists("www/icons/materialicons/")) {
      message("[shinymaterial] Creating directory: www/icons/materialicons/")
      dir.create("www/icons/materialicons/", recursive = TRUE)
    }
    
    for (icon_file.i in icons_files) {
      file.copy(
        from = icon_file.i,
        to = "www/icons/materialicons/",
        overwrite = TRUE, recursive = TRUE
      )
    }
    
    icon_css <- system.file("css/shiny-material-icons.css", package = "shinymaterial")
    
  } else {
    
    icon_css <- "https://fonts.googleapis.com/icon?family=Material+Icons"
    
  }
  
  material_nav_bar <- shiny::tags$nav(
    class = 
      ifelse(
        is.null(nav_bar_color),
        "",
        nav_bar_color
      ),
    shiny::tags$div(
      class = "nav-wrapper",
      shiny::tags$div(
        href = "javascript:void(0)",
        class = paste0(
          "brand-logo ",
          ifelse(
            is.null(font_color),
            "",
            paste0(" ", font_color, "-text")
          )
        ),
        shiny::HTML(paste0("&nbsp;", title))
      )
    )
  )
  
  if(nav_bar_fixed){
    material_nav_bar <- shiny::tags$div(
      class = "navbar-fixed",
      material_nav_bar
    )
  }
  
  if(!include_nav_bar){
    material_nav_bar <- shiny::tags$div()
  }
  
  shiny::tags$html(
    # Head --------------------------------------------------------------------
    shiny::tags$head(
      # Fonts
      shiny::includeCSS(
        icon_css
      ),
      # Source Materialize CSS
      shiny::includeCSS(
        css_location,
        media = "screen,projection"
      ),
      shiny::includeCSS(
        system.file("css/shiny-material-page.css",
                    package = "shinymaterial")
      ),
      shiny::tags$meta(
        name="viewport",
        content="width=device-width, initial-scale=1.0"
      )
    ),
    # Body --------------------------------------------------------------------
    shiny::tags$body(
      class = background_color,
      material_nav_bar,
      ...
    ),
    # Source Materialize Javascript
    shiny::includeScript(
      js_location
    ),
    shiny::includeScript(
      system.file("js/shiny-material-page.js",
                  package = "shinymaterial")
    ),
    shiny::tags$script("
                       Shiny.addCustomMessageHandler('shinymaterialJS',
                       function(code) {
                       //console.log(code.split('\\\\').join('').trim());
                       eval(code.split('\\\\').join('').trim());
                       });
                       ")
  )
}
