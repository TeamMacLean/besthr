#' besthr color palettes
#'
#' Returns a color palette suitable for besthr visualizations. The default
#' palette uses Okabe-Ito colorblind-safe colors.
#'
#' @param palette Character string specifying the palette. Options are:
#'   \itemize{
#'     \item "default" - Original besthr colors
#'     \item "okabe_ito" - Colorblind-safe Okabe-Ito palette
#'     \item "viridis" - Viridis color scale
#'   }
#' @param n Number of colors to return. If NULL, returns all colors in palette.
#'
#' @return A character vector of hex color codes
#' @export
#'
#' @examples
#' besthr_palette()
#' besthr_palette("okabe_ito", 3)
#'
besthr_palette <- function(palette = "default", n = NULL) {
  palettes <- list(
    default = c(
      "#F8766D", "#00BA38", "#619CFF", "#F564E3",
      "#00BFC4", "#B79F00", "#FF6C91", "#00B0F6"
    ),
    okabe_ito = c(
      "#E69F00", "#56B4E9", "#009E73", "#F0E442",
      "#0072B2", "#D55E00", "#CC79A7", "#999999"
    ),
    viridis = viridisLite::viridis(8)
  )

  pal <- palettes[[palette]]
  if (is.null(pal)) {
    stop("Unknown palette: ", palette,
         ". Choose from: ", paste(names(palettes), collapse = ", "))
  }

  if (!is.null(n)) {
    if (n > length(pal)) {
      pal <- grDevices::colorRampPalette(pal)(n)
    } else {
      pal <- pal[seq_len(n)]
    }
  }

  pal
}

#' besthr ggplot2 theme
#'
#' A custom theme for besthr plots. The "classic" theme matches the original
#' besthr appearance, while "modern" provides a cleaner, more contemporary look.
#'
#' @param style Character string specifying the theme style. Options are:
#'   \itemize{
#'     \item "classic" - Original besthr theme (theme_minimal)
#'     \item "modern" - Clean, contemporary style with refined typography
#'   }
#' @param base_size Base font size (default 11)
#' @param base_family Base font family
#'
#' @return A ggplot2 theme object
#' @export
#'
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(mpg, wt)) +
#'   geom_point() +
#'   theme_besthr("modern")
#'
theme_besthr <- function(style = "classic", base_size = 11, base_family = "") {
  if (style == "classic") {
    return(ggplot2::theme_minimal(base_size = base_size, base_family = base_family))
  }

  if (style == "modern") {
    return(
      ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
        ggplot2::theme(
          # Typography
          plot.title = ggplot2::element_text(
            size = ggplot2::rel(1.2),
            face = "bold",
            margin = ggplot2::margin(b = 10)
          ),
          axis.title = ggplot2::element_text(
            size = ggplot2::rel(1.0),
            face = "bold"
          ),
          axis.text = ggplot2::element_text(size = ggplot2::rel(0.9)),
          legend.title = ggplot2::element_text(face = "bold"),

          # Grid
          panel.grid.minor = ggplot2::element_blank(),
          panel.grid.major = ggplot2::element_line(
            color = "grey90",
            linewidth = 0.3
          ),

          # Legend
          legend.position = "bottom",
          legend.box = "horizontal",

          # Spacing
          plot.margin = ggplot2::margin(15, 15, 15, 15),

          # Strip (for facets)
          strip.text = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.0)),
          strip.background = ggplot2::element_blank()
        )
    )
  }

  stop("Unknown style: ", style, ". Choose from: classic, modern")
}

#' Discrete color scale for besthr
#'
#' A discrete color scale using besthr palettes.
#'
#' @param palette Character string specifying the palette (see \code{\link{besthr_palette}})
#' @param ... Additional arguments passed to \code{\link[ggplot2]{discrete_scale}}
#'
#' @return A ggplot2 discrete color scale
#' @export
#'
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(mpg, wt, color = factor(cyl))) +
#'   geom_point() +
#'   scale_color_besthr("okabe_ito")
#'
scale_color_besthr <- function(palette = "default", ...) {
  ggplot2::discrete_scale(
    aesthetics = "colour",
    palette = function(n) besthr_palette(palette, n),
    ...
  )
}

#' @rdname scale_color_besthr
#' @export
scale_colour_besthr <- scale_color_besthr

#' Discrete fill scale for besthr
#'
#' A discrete fill scale using besthr palettes.
#'
#' @param palette Character string specifying the palette (see \code{\link{besthr_palette}})
#' @param ... Additional arguments passed to \code{\link[ggplot2]{discrete_scale}}
#'
#' @return A ggplot2 discrete fill scale
#' @export
#'
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(factor(cyl), fill = factor(cyl))) +
#'   geom_bar() +
#'   scale_fill_besthr("okabe_ito")
#'
scale_fill_besthr <- function(palette = "default", ...) {
  ggplot2::discrete_scale(
    aesthetics = "fill",
    palette = function(n) besthr_palette(palette, n),
    ...
  )
}

#' Confidence interval fill colors
#'
#' Returns the fill colors used for confidence interval regions in bootstrap
#' distribution plots.
#'
#' @param style Character string: "default" for original colors, "modern" for
#'   updated colors
#'
#' @return A named character vector of hex colors for low, middle, high regions
#' @keywords internal
#'
ci_fill_colors <- function(style = "default") {
  if (style == "default") {
    return(c("#0000FFA0", "#A0A0A0A0", "#FF0000A0"))
  }

  if (style == "modern") {
    return(c("#2166AC99", "#F7F7F799", "#B2182B99"))
  }

  stop("Unknown style: ", style)
}
