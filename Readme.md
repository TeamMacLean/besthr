besthr - Generating Bootstrap Estimation Distributions of HR Data
================
Dan MacLean
16 January, 2026

<!-- badges: start -->
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3374507.svg)](https://doi.org/10.5281/zenodo.3374507)
[![R-CMD-check](https://github.com/TeamMacLean/besthr/workflows/R-CMD-check/badge.svg)](https://github.com/TeamMacLean/besthr/actions)
<!-- badges: end -->

## Synopsis

besthr is a package that creates plots showing scored HR experiments and
plots of distribution of means of ranks of HR score from bootstrapping.

## Installation

You can install from CRAN in the usual way.

``` r
install.packages("besthr")

# or for the dev version
#install.packages("devtools")
devtools::install_github("TeamMacLean/besthr")
```

## Citation

Please cite as

> Dan MacLean. (2019). TeamMacLean/besthr: Initial Release (0.3.0).
> Zenodo. <https://doi.org/10.5281/zenodo.3374507>

## Simplest Use Case - Two Groups, No Replicates

With a data frame or similar object, use the `estimate()` function to
get the bootstrap estimates of the ranked data.

`estimate()` has a basic function call as follows:

`estimate(data, score_column_name, group_column_name, control = control_group_name)`

The first argument after the

``` r
library(besthr)

hr_data_1_file <- system.file("extdata", "example-data-1.csv", package = "besthr")
hr_data_1 <- readr::read_csv(hr_data_1_file)
```

    ## Rows: 20 Columns: 2
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr (1): group
    ## dbl (1): score
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
head(hr_data_1)
```

    ## # A tibble: 6 × 2
    ##   score group
    ##   <dbl> <chr>
    ## 1    10 A    
    ## 2     9 A    
    ## 3    10 A    
    ## 4    10 A    
    ## 5     8 A    
    ## 6     8 A

``` r
hr_est_1 <- estimate(hr_data_1, score, group, control = "A")
hr_est_1
```

    ## besthr (HR Rank Score Analysis with Bootstrap Estimation)
    ## =========================================================
    ## 
    ## Control: A
    ## 
    ## Unpaired mean rank difference of A (14.9, n=10) minus B (6.1, n=10)
    ##  8.8
    ## Confidence Intervals (0.025, 0.975)
    ##  3.5375, 8.17625
    ## 
    ## 100 bootstrap resamples.

``` r
plot(hr_est_1)
```

    ## Confidence interval: 2.5% - 97.5%

![](README_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

### Setting Options

You may select the group to set as the common reference control with
`control`.

``` r
estimate(hr_data_1, score, group, control = "B" ) %>%
  plot()
```

    ## Confidence interval: 2.5% - 97.5%

![](README_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

You may select the number of iterations of the bootstrap to perform with
`nits` and the quantiles for the confidence interval with `low` and
`high`.

``` r
estimate(hr_data_1, score, group, control = "A", nits = 1000, low = 0.4, high = 0.6) %>%
  plot()
```

    ## Confidence interval: 40.0% - 60.0%

![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

## Extended Use Case - Technical Replicates

You can extend the `estimate()` options to specify a third column in the
data that contains technical replicate information, add the technical
replicate column name after the sample column. Technical replicates are
automatically merged using the `mean()` function before ranking.

``` r
hr_data_3_file <- system.file("extdata", "example-data-3.csv", package = "besthr")
hr_data_3 <- readr::read_csv(hr_data_3_file)
```

    ## Rows: 36 Columns: 3
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr (1): sample
    ## dbl (2): score, rep
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
head(hr_data_3)
```

    ## # A tibble: 6 × 3
    ##   score sample   rep
    ##   <dbl> <chr>  <dbl>
    ## 1     8 A          1
    ## 2     9 A          1
    ## 3     8 A          1
    ## 4    10 A          1
    ## 5     8 A          2
    ## 6     8 A          2

``` r
hr_est_3 <- estimate(hr_data_3, score, sample, rep, control = "A")

hr_est_3
```

    ## besthr (HR Rank Score Analysis with Bootstrap Estimation)
    ## =========================================================
    ## 
    ## Control: A
    ## 
    ## Unpaired mean rank difference of A (5, n=3) minus B (2, n=3)
    ##  3
    ## Confidence Intervals (0.025, 0.975)
    ##  1.15833333333333, 3
    ## 
    ## Unpaired mean rank difference of A (5, n=3) minus C (8, n=3)
    ##  -3
    ## Confidence Intervals (0.025, 0.975)
    ##  7.33333333333333, 9
    ## 
    ## 100 bootstrap resamples.

``` r
plot(hr_est_3)
```

    ## Confidence interval: 2.5% - 97.5%

![](README_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

### Alternate Plot Options

In the case where you have use technical replicates and want to see
those plotted you can use an extra plot option `which`. Set `which` to
`just_data` if you wish the left panel of the plot to show all data
without ranking. This will only work if you have technical replicates.

``` r
hr_est_3 %>%
  plot(which = "just_data")
```

    ## Confidence interval: 2.5% - 97.5%

![](README_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

## Built-in Themes and Color Palettes

besthr includes built-in themes and colorblind-safe color palettes that
can be applied directly through the `plot()` function.

### Theme Options

Use the `theme` parameter to change the overall visual style:

- `"classic"` (default) - The original besthr appearance
- `"modern"` - A cleaner, contemporary style with refined typography and
  grid

``` r
# Classic theme (default - same as before)
plot(hr_est_1, theme = "classic")
```

    ## Confidence interval: 2.5% - 97.5%

![](README_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

``` r
# Modern theme
plot(hr_est_1, theme = "modern")
```

    ## Confidence interval: 2.5% - 97.5%

![](README_files/figure-gfm/unnamed-chunk-7-2.png)<!-- -->

### Color Palette Options

Use the `colors` parameter to change the color palette:

- `"default"` - Original besthr colors
- `"okabe_ito"` - Colorblind-safe Okabe-Ito palette
- `"viridis"` - Viridis color scale

``` r
# Colorblind-safe palette
plot(hr_est_1, colors = "okabe_ito")
```

    ## Confidence interval: 2.5% - 97.5%

![](README_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

``` r
# Viridis palette
plot(hr_est_1, colors = "viridis")
```

    ## Confidence interval: 2.5% - 97.5%

![](README_files/figure-gfm/unnamed-chunk-8-2.png)<!-- -->

### Combining Theme and Colors

You can combine both options for a fully customized look:

``` r
# Modern theme with colorblind-safe colors
plot(hr_est_1, theme = "modern", colors = "okabe_ito")
```

    ## Confidence interval: 2.5% - 97.5%

![](README_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

### Using besthr Palettes Directly

The color palettes can also be used directly in your own ggplot2 code:

``` r
# Get palette colors
besthr_palette("okabe_ito", n = 4)
```

    ## [1] "#E69F00" "#56B4E9" "#009E73" "#F0E442"

``` r
# Available palettes
besthr_palette("default", n = 3)
```

    ## [1] "#F8766D" "#00BA38" "#619CFF"

``` r
besthr_palette("viridis", n = 3)
```

    ## [1] "#440154FF" "#46337EFF" "#365C8DFF"

## Styling Plots

You can style plots to your own taste. The object returned from `plot()`
is a `patchwork` <https://patchwork.data-imaginist.com/> object that
composes two separate plots, the dot plot and the bootstrap percentile
plot, which are themselves `ggplot` objects. So you can use a mixture of
`patchwork` annotations functions for whole plot labels and `ggplot`
themes for individual elements.

### Adding annotations.

You can use the `patchwork` `plot_annotation()` function to add titles

``` r
library(patchwork)

p <- plot(hr_est_1)
```

    ## Confidence interval: 2.5% - 97.5%

``` r
p + plot_annotation(title = 'A stylish besthr plot', 
                    subtitle = "better than ever", 
                    caption = 'Though this example is not meaningful')
```

![](README_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->

``` r
p
```

![](README_files/figure-gfm/unnamed-chunk-11-2.png)<!-- -->

### Targetting a subplot to make theme changes

You can change the style of the individual plot elements using
subsetting syntax `[[]]` . The dot plot can be addressed within the
`patchwork` object using index 1 within the `patchwork` object `p[[1]]`,
and the percentile plot using `p[[2]]`. You must add to the existing
subplot then assign the result back to see the difference in the plot.
Here’s an example that uses `theme()` to restyle the y-axis text of the
dot plot

``` r
library(ggplot2)
```

    ## Warning: package 'ggplot2' was built under R version 4.5.2

``` r
p[[1]] <- p[[1]] + theme(axis.title.y = element_text(family = "Times", colour="blue", size=24))
p
```

![](README_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

### Changing the scale colours of a subplot

You can change the colours used by the scales in the same way using the
`scale` functions, though as the type of scale is different for the dot
plot and bootstrap plot you will need to apply a different scale for
each.

For the dot plot, use a discrete scale e.g `scale_colour_manual()`,
`scale_colour_viridis_d()` or `scale_colour_brewer(type = "qual")`

``` r
p[[1]] <- p[[1]] + scale_colour_manual(values = c("blue", "#440000"))
```

    ## Scale for colour is already present.
    ## Adding another scale for colour, which will replace the existing scale.

``` r
p
```

![](README_files/figure-gfm/unnamed-chunk-13-1.png)<!-- -->

``` r
p[[1]] <- p[[1]] + scale_colour_viridis_d()
```

    ## Scale for colour is already present.
    ## Adding another scale for colour, which will replace the existing scale.

``` r
p
```

![](README_files/figure-gfm/unnamed-chunk-13-2.png)<!-- -->

``` r
p[[1]] <- p[[1]] + scale_colour_brewer(type="qual", palette="Accent")
```

    ## Scale for colour is already present.
    ## Adding another scale for colour, which will replace the existing scale.

``` r
p
```

![](README_files/figure-gfm/unnamed-chunk-13-3.png)<!-- -->

For the percentile plot, use only `scale_colour_manual()` with specified
colours. Annoyingly, this rewrites the other values associated with the
scale each time, so you’ll need to replace those.

``` r
p[[2]] <- p[[2]] + scale_fill_manual(
  values = c("blue", "pink", "yellow"),
  name = "bootstrap percentile", labels=c("lower", "non-significant", "higher"),
  guide = guide_legend(reverse=TRUE)
  )
p
```

![](README_files/figure-gfm/unnamed-chunk-14-1.png)<!-- -->

## Alternative Visualizations

### Forest Plot

For publication-style forest plots showing point estimates with
confidence intervals:

``` r
# Basic forest plot
plot_forest(hr_est_1)
```

![](README_files/figure-gfm/unnamed-chunk-15-1.png)<!-- -->

``` r
# With theme options
plot_forest(hr_est_1, theme = "modern", colors = "okabe_ito")
```

![](README_files/figure-gfm/unnamed-chunk-15-2.png)<!-- -->

### Raincloud Plot

For a combined view of raw data, density, and summary statistics:

``` r
plot_raincloud(hr_est_1)
```

![](README_files/figure-gfm/unnamed-chunk-16-1.png)<!-- -->

## Significance and Effect Size Annotations

You can add statistical annotations to your plots to highlight
significant results.

### Significance Stars

Add significance stars to groups where the bootstrap confidence interval
does not overlap the control mean:

``` r
# Create data with a clear difference for demonstration
d_sig <- data.frame(
  score = c(rep(2, 10), rep(8, 10)),
  group = rep(c("A", "B"), each = 10)
)
hr_sig <- estimate(d_sig, score, group, control = "A", nits = 500)

# Plot with significance annotation
plot(hr_sig, show_significance = TRUE)
```

    ## Confidence interval: 2.5% - 97.5%

![](README_files/figure-gfm/unnamed-chunk-17-1.png)<!-- -->

### Effect Size Annotation

Display effect size (difference from control) with confidence intervals:

``` r
plot(hr_sig, show_effect_size = TRUE)
```

    ## Confidence interval: 2.5% - 97.5%

![](README_files/figure-gfm/unnamed-chunk-18-1.png)<!-- -->

### Computing Statistics Directly

You can also access the significance and effect size calculations
directly:

``` r
# Compute significance
compute_significance(hr_est_1)
```

    ##   group significant p_value stars
    ## 1     A          NA      NA      
    ## 2     B        TRUE       0   ***

``` r
# Compute effect sizes
compute_effect_size(hr_est_1)
```

    ##   group effect effect_ci_low effect_ci_high
    ## 1     A     NA            NA             NA
    ## 2     B   -8.8      -11.3625       -6.72375

## Summary Tables

Generate publication-ready summary tables with `besthr_table()`:

``` r
# Default tibble format
besthr_table(hr_est_1)
```

    ## # A tibble: 2 × 6
    ##   group     n mean_rank ci_low ci_high effect_size
    ##   <chr> <int>     <dbl>  <dbl>   <dbl>       <dbl>
    ## 1 A        10      14.9  NA      NA           NA  
    ## 2 B        10       6.1   3.54    8.18        -8.8

``` r
# With significance stars
besthr_table(hr_sig, include_significance = TRUE)
```

    ## # A tibble: 2 × 7
    ##   group     n mean_rank ci_low ci_high effect_size significance
    ##   <chr> <int>     <dbl>  <dbl>   <dbl>       <dbl> <chr>       
    ## 1 A        10       5.5   NA      NA            NA ""          
    ## 2 B        10      15.5   15.5    15.5          10 "***"

### Export Formats

Generate tables in various formats for publication:

``` r
# Markdown format
besthr_table(hr_est_1, format = "markdown")
```

    ## [1] "| group | n | mean_rank | ci_low | ci_high | effect_size |\n| --- | --- | --- | --- | --- | --- |\n| A | 10 | 14.9 | NA | NA | NA |\n| B | 10 |  6.1 | 3.54 | 8.18 | -8.8 |"

``` r
# HTML format
besthr_table(hr_est_1, format = "html")

# LaTeX format
besthr_table(hr_est_1, format = "latex")
```

## Publication Export

Save your plots directly to publication-quality files:

``` r
# Save to PNG (default 300 DPI)
save_besthr(hr_est_1, "figure1.png")

# Save to PDF
save_besthr(hr_est_1, "figure1.pdf", width = 10, height = 8)

# Save forest plot
save_besthr(hr_est_1, "forest.png", type = "forest")

# Save raincloud plot
save_besthr(hr_est_1, "raincloud.png", type = "raincloud")

# With custom options
save_besthr(hr_est_1, "figure1.png",
            theme = "modern",
            colors = "okabe_ito",
            width = 10,
            height = 6,
            dpi = 600)
```

Supported formats: PNG, PDF, SVG, TIFF, JPEG
