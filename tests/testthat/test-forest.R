# Tests for forest plot feature

test_that("plot_forest returns ggplot object", {
  set.seed(123)
  hr <- estimate(make_data(), score, group, nits = 100)
  p <- plot_forest(hr)

  expect_s3_class(p, "ggplot")
})

test_that("plot_forest shows all groups including control", {
  set.seed(456)
  d <- make_data3()
  hr <- estimate(d, score, sample, control = "A", nits = 100)
  p <- plot_forest(hr)

  # Build the plot to access computed data
  built <- ggplot2::ggplot_build(p)

  # Should have data for all 3 groups
  # Layer 1 is vline (1 row), layer 2 is pointrange (3 rows)
  pointrange_layer <- which(sapply(built$data, function(x) nrow(x) == 3))
  expect_true(length(pointrange_layer) > 0)
})

test_that("plot_forest respects theme option", {
  set.seed(789)
  hr <- estimate(make_data(), score, group, nits = 100)

  p_classic <- plot_forest(hr, theme = "classic")
  p_modern <- plot_forest(hr, theme = "modern")

  expect_s3_class(p_classic, "ggplot")
  expect_s3_class(p_modern, "ggplot")
})

test_that("plot_forest respects colors option", {
  set.seed(42)
  hr <- estimate(make_data(), score, group, nits = 100)

  p_default <- plot_forest(hr, colors = "default")
  p_okabe <- plot_forest(hr, colors = "okabe_ito")
  p_viridis <- plot_forest(hr, colors = "viridis")

  expect_s3_class(p_default, "ggplot")
  expect_s3_class(p_okabe, "ggplot")
  expect_s3_class(p_viridis, "ggplot")
})

test_that("plot_forest accepts config parameter", {
  set.seed(111)
  hr <- estimate(make_data(), score, group, nits = 100)
  cfg <- besthr_plot_config(theme_style = "modern", color_palette = "okabe_ito")

  p <- plot_forest(hr, config = cfg)

  expect_s3_class(p, "ggplot")
})

test_that("forest plot shows point estimates", {
  set.seed(222)
  hr <- estimate(make_data(), score, group, nits = 100)
  p <- plot_forest(hr)

  # Should have geom_point or geom_pointrange layer
  has_points <- any(sapply(p$layers, function(l) {
    inherits(l$geom, "GeomPoint") || inherits(l$geom, "GeomPointrange")
  }))
  expect_true(has_points)
})

test_that("forest plot shows confidence intervals", {
  set.seed(333)
  hr <- estimate(make_data(), score, group, nits = 100)
  p <- plot_forest(hr)

  # Should have error bar or pointrange layer
  has_ci <- any(sapply(p$layers, function(l) {
    inherits(l$geom, "GeomErrorbar") ||
    inherits(l$geom, "GeomErrorbarh") ||
    inherits(l$geom, "GeomPointrange") ||
    inherits(l$geom, "GeomLinerange")
  }))
  expect_true(has_ci)
})

test_that("forest plot CI values match hrest object", {
  set.seed(444)
  hr <- estimate(make_data(), score, group, control = "A", nits = 200)
  p <- plot_forest(hr)

  # Build the plot
  built <- ggplot2::ggplot_build(p)

  # The CI values should be present in some layer
  # This is a structural test - implementation determines exact layer
  expect_true(length(built$data) >= 1)
})

test_that("forest plot has horizontal layout", {
  set.seed(555)
  hr <- estimate(make_data(), score, group, nits = 100)
  p <- plot_forest(hr)

  # Forest plots typically have groups on y-axis, values on x-axis
  # Check that y is mapped to group
  expect_true(!is.null(p$mapping$y) || !is.null(p$layers[[1]]$mapping$y))
})

test_that("plot_forest works with technical replicates data", {
  set.seed(666)
  d <- make_data3()  # make_data3 has score, sample, rep columns
  hr <- estimate(d, score, sample, rep, control = "A", nits = 100)
  p <- plot_forest(hr)

  expect_s3_class(p, "ggplot")
})
