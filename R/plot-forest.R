#' Forest plot for besthr results
#'
#' Creates a classic forest plot showing point estimates and confidence intervals
#' for all groups. This is a standard visualization format commonly used in
#' publications and meta-analyses.
#'
#' @param hrest An hrest object from \code{\link{estimate}}
#' @param theme The visual theme: "modern" (default) or "classic"
#' @param colors The color palette: "okabe_ito" (default), "default", or "viridis"
#' @param config An optional besthr_plot_config object for advanced customization
#' @param show_null Logical, whether to show vertical line at control mean (default TRUE)
#'
#' @return A ggplot object
#'
#' @export
#'
#' @examples
#' d <- make_data()
#' hr <- estimate(d, score, group, nits = 500)
#' plot_forest(hr)
#' plot_forest(hr, theme = "classic", colors = "viridis")
#'
plot_forest <- function(hrest, theme = "modern", colors = "okabe_ito",
                        config = NULL, show_null = TRUE) {
  if (!inherits(hrest, "hrest")) {
    stop("hrest must be an hrest object from estimate()")
  }

  # Build config from parameters or use provided config
  if (is.null(config)) {
    config <- besthr_plot_config(
      theme_style = theme,
      color_palette = colors
    )
  }

  # Get group column name
  group_col_name <- names(hrest$group_n)[names(hrest$group_n) != "n"][[1]]
  group_col <- rlang::sym(group_col_name)

  # Build data for forest plot
  # Combine group means with CI
  forest_data <- hrest$group_means

  # For control group, use its own bootstrap CI if available, otherwise just mean
  # For treatment groups, use the CI from bootstrap
  forest_data$ci_low <- NA_real_
  forest_data$ci_high <- NA_real_

  for (i in seq_len(nrow(forest_data))) {
    g <- forest_data[[group_col_name]][i]
    if (g == hrest$control) {
      # Control group - compute CI from its bootstrap distribution
      control_boots <- hrest$bootstraps$mean[hrest$bootstraps[[group_col_name]] == g]
      if (length(control_boots) > 0) {
        forest_data$ci_low[i] <- stats::quantile(control_boots, hrest$low)
        forest_data$ci_high[i] <- stats::quantile(control_boots, hrest$high)
      } else {
        # No bootstrap for control - use point estimate only
        forest_data$ci_low[i] <- forest_data$mean[i]
        forest_data$ci_high[i] <- forest_data$mean[i]
      }
    } else {
      # Treatment group - use CI from hrest$ci
      ci_row <- hrest$ci[hrest$ci[[group_col_name]] == g, ]
      if (nrow(ci_row) > 0) {
        forest_data$ci_low[i] <- ci_row$low
        forest_data$ci_high[i] <- ci_row$high
      }
    }
  }

  # Ensure group is a factor with consistent levels
  forest_data[[group_col_name]] <- factor(
    forest_data[[group_col_name]],
    levels = rev(unique(forest_data[[group_col_name]]))  # Reverse for top-to-bottom order
  )

  # Get control mean for null line
  control_mean <- forest_data$mean[forest_data[[group_col_name]] == hrest$control]

  # Build the plot
  p <- ggplot2::ggplot(forest_data, ggplot2::aes(
    x = mean,
    y = !!group_col,
    xmin = ci_low,
    xmax = ci_high,
    colour = !!group_col
  ))

  # Add null line (control mean) if requested
  if (show_null && length(control_mean) > 0) {
    p <- p + ggplot2::geom_vline(
      xintercept = control_mean,
      linetype = "dashed",
      colour = "gray50",
      linewidth = 0.5
    )
  }

  # Add point estimate with CI
  p <- p + ggplot2::geom_pointrange(size = 0.8, linewidth = 1)

  # Labels
  p <- p + ggplot2::labs(
    x = "Mean Rank",
    y = NULL,
    title = NULL
  )

  # Apply theme
  p <- p + theme_besthr(config$theme_style)

  # Apply color palette with drop = FALSE for consistency
  if (config$color_palette != "default") {
    p <- p + scale_color_besthr(config$color_palette, drop = FALSE)
  } else {
    p <- p + ggplot2::scale_colour_discrete(drop = FALSE)
  }

  # Remove legend (color is redundant with y-axis labels)
  p <- p + ggplot2::guides(colour = "none")

  # Add some padding to x-axis
  x_range <- range(c(forest_data$ci_low, forest_data$ci_high), na.rm = TRUE)
  x_padding <- diff(x_range) * 0.1
  p <- p + ggplot2::xlim(x_range[1] - x_padding, x_range[2] + x_padding)

  p
}
