# CLAUDE.md - besthr Development Guide

## Project Overview

**besthr** is an R package for generating bootstrap estimation distributions of HR (Hypersensitive Response) data from plant pathology experiments. It creates publication-ready visualizations showing scored HR experiments with bootstrap confidence intervals.

- **Version**: 0.3.2
- **CRAN Status**: Published
- **License**: MIT
- **DOI**: 10.5281/zenodo.3374507

## Quick Start

```r
# Restore renv environment
renv::restore()

# Install development dependencies
renv::install(c("devtools", "testthat"))

# Common development commands
devtools::load_all()     # Load package for interactive use
devtools::test()         # Run testthat tests
devtools::check()        # Full R CMD check
devtools::document()     # Regenerate documentation
```

## Architecture

### Core Object: `hrest`

The package centers around the `hrest` S3 class returned by `estimate()`:

```
hrest object structure:
├── control         # Character: control group name (default "A")
├── group_means     # tibble: mean rank per group
├── ranked_data     # tibble: data with rank column (tech reps averaged)
├── original_data   # tibble: raw input data with rank column
├── bootstraps      # tibble: bootstrap mean ranks per iteration/group
├── ci              # tibble: confidence interval bounds per group
├── nits            # Integer: number of bootstrap iterations
├── low             # Numeric: lower quantile bound
├── high            # Numeric: upper quantile bound
├── group_n         # tibble: sample size per group
└── column_info     # list: quosures of input column names
```

### Data Flow

```
User Data (tibble)
       │
       ▼
  estimate()
       │
       ├──► add_rank()           # Compute score ranks
       │
       ├──► [if tech reps]       # Average technical replicates
       │     group_by + summarize
       │
       ├──► bootstrap_dist()     # N iterations of resampling
       │     └── bstrap_sample() # Single bootstrap iteration
       │
       └──► conf_intervals()     # Compute quantiles
              │
              ▼
         hrest object
              │
              ▼
         plot.hrest()
              │
              ├──► dot_plot()         # Left panel: ranked scores
              │    or
              │    tech_rep_dot_plot() # Left panel: raw scores by rep
              │
              └──► ggridges density   # Right panel: bootstrap dist
                      │
                      ▼
               patchwork layout
```

### Key Files

| File | Purpose |
|------|---------|
| `R/functions.R` | Core logic: estimate(), print.hrest(), bootstrap helpers |
| `R/plot-config.R` | Configuration system: besthr_plot_config(), besthr_style() |
| `R/plot-layers.R` | Data view and composable layer functions |
| `R/plot-panels.R` | Panel builders: build_observation_panel(), build_bootstrap_panel() |
| `R/plot-hrest.R` | Main plot.hrest() and legacy helpers |
| `R/plot-raincloud.R` | Alternative visualizations |
| `R/themes.R` | Theming: theme_besthr(), color palettes, scales |
| `R/utils-pipe.R` | Re-export of magrittr pipe |
| `tests/testthat/` | Test files for all exported functions |
| `vignettes/basic-use.Rmd` | User-facing vignette |

## Development Guidelines

### Backward Compatibility (Critical)

This is a CRAN package. Any change must preserve existing behavior:

1. **Function signatures**: Never remove or reorder existing parameters
2. **Return values**: Never change the structure of returned objects
3. **Default behavior**: New parameters must default to existing behavior
4. **Deprecation**: Use `.Deprecated()` for phasing out, never hard-remove

### Code Style

- Use tidyverse style (magrittr pipes, dplyr verbs)
- Quosure handling for column names via `rlang::enquos(...)`
- Document with roxygen2 (`#'` comments)
- Internal functions marked with `@keywords internal`

### Adding Parameters to Existing Functions

```r
# CORRECT: Add with default that preserves behavior
plot.hrest <- function(x, ..., which = "rank_simulation",
                       new_param = "default_value") {
  # Implementation
}

# INCORRECT: Changing defaults or removing params
plot.hrest <- function(x, new_required_param, ...) {
  # This breaks existing code!
}
```

### Adding New Plot Options

When adding themes or visual options:

1. Add parameter with backward-compatible default
2. Keep existing code path for default case
3. Add new code path for new options
4. Test that default case produces identical output

## CI/CD Pipeline

### GitHub Actions Workflows

- **R-CMD-check.yaml**: Matrix testing across R versions and platforms
- **test-coverage.yaml**: Coverage reporting via codecov
- **lint.yaml**: Static analysis with lintr

### Pre-commit Checks

Before pushing:
```r
devtools::test()      # All tests pass
devtools::check()     # No ERRORs or WARNINGs
```

## Common Tasks

### Running Tests

```r
# All tests
devtools::test()

# Specific test file
testthat::test_file("tests/testthat/test-estimate.R")

# With verbose output
devtools::test(reporter = "summary")
```

### Regenerating Documentation

```r
devtools::document()
# Then check: man/*.Rd files updated
```

### Building for CRAN

```r
# Full check mimicking CRAN
devtools::check(cran = TRUE)

# Build tarball
devtools::build()
```

## Gotchas

### Quosure Handling

Column names are passed as bare symbols and captured with `enquos()`:

```r
estimate(df, score, group)  # NOT "score", "group"

# Inside function:
quo_list <- dplyr::enquos(...)
quo_score_col <- quo_list[[1]]
# Use with !! to unquote
df %>% dplyr::mutate(rank = rank(!!quo_score_col))
```

### Bootstrap Reproducibility

Bootstrap results are stochastic. For reproducible tests:

```r
set.seed(123)
hr <- estimate(d, score, group, nits = 100)
```

### ggplot2 Deprecations

Current code uses deprecated `size` parameter in `geom_hline()`. Use `linewidth` instead:

```r
# Old (deprecated)
geom_hline(..., size = 1)

# New
geom_hline(..., linewidth = 1)
```

### tidyselect .data Usage

The `.data` pronoun is deprecated in tidyselect contexts. Use string column names:

```r
# Deprecated
dplyr::select(df, -.data$n)

# Preferred
dplyr::select(df, -"n")
```

## Release Checklist

1. **Update version** in DESCRIPTION
2. **Update NEWS.md** (if exists)
3. **Run full checks**:
   ```r
   devtools::check(cran = TRUE)
   ```
4. **Check reverse dependencies** (if any)
5. **Submit to CRAN** via `devtools::release()` or web form
6. **Tag release** in git:
   ```bash
   git tag -a v0.x.y -m "Release version 0.x.y"
   git push origin v0.x.y
   ```

## Sample Data

The package includes example data generators:

```r
make_data()   # 2 groups, 10 obs each, no tech reps
make_data2()  # 2 groups, 12 obs each, 3 tech reps
make_data3()  # 3 groups, 12 obs each, 3 tech reps
```

External data files in `inst/extdata/`:
- `example-data-1.csv`
- `example-data-2.csv`
- `example-data-3.csv`

## Upcoming Features Development Plan

Development follows **Test-Driven Development (TDD)**:
1. Write failing tests first
2. Implement minimum code to pass
3. Refactor while keeping tests green
4. Document and update README/vignette

### Feature 1: Significance Annotations

**Description**: Auto-detect when bootstrap CI doesn't overlap with control mean rank and add significance markers (`*`, `**`, `***`).

**API**:
```r
plot(hr, show_significance = TRUE)  # Add * markers to significant groups
```

**Test Conditions** (write tests FIRST):
```r
test_that("significance annotations appear when CI doesn't overlap control", {
  set.seed(123)
  d <- make_data()  # Groups with clear separation
  hr <- estimate(d, score, group, nits = 500)
  p <- plot(hr, show_significance = TRUE)

  # Check that annotation layer exists

  expect_true(any(sapply(p[[1]]$layers, function(l) inherits(l$geom, "GeomText"))))
})

test_that("significance annotations hidden by default", {
  hr <- estimate(make_data(), score, group, nits = 100)
  p <- plot(hr)
  # No text annotations by default
  expect_false(any(sapply(p[[1]]$layers, function(l) inherits(l$geom, "GeomText"))))
})

test_that("significance levels are correct", {
  # * for p < 0.05, ** for p < 0.01, *** for p < 0.001
  # Based on proportion of bootstrap samples overlapping control
})
```

**Implementation File**: `R/plot-panels.R` (add to observation panel)

---

### Feature 2: Effect Size Annotation

**Description**: Optional annotation showing mean rank difference between treatment and control with CI.

**API**:
```r
plot(hr, show_effect_size = TRUE)  # Add effect size annotation
```

**Test Conditions**:
```r
test_that("effect size annotation shows difference from control", {
  hr <- estimate(make_data(), score, group, control = "A", nits = 100)
  p <- plot(hr, show_effect_size = TRUE)

  # Should have annotation showing difference
  expect_true(any(grepl("effect|diff", class(p), ignore.case = TRUE)) ||
              any(sapply(p$patches$plots, function(x) length(x$labels) > 2)))
})

test_that("effect size values are mathematically correct", {
  set.seed(42)
  hr <- estimate(make_data(), score, group, control = "A", nits = 100)
  # Effect should equal mean(B) - mean(A)
  expected_effect <- hr$group_means$mean[2] - hr$group_means$mean[1]
  # Verify annotation contains this value
})
```

**Implementation File**: `R/plot-panels.R` or new annotation layer

---

### Feature 3: Forest Plot Alternative

**Description**: Classic forest plot showing all groups as horizontal bars with CI - standard in publications.

**API**:
```r
plot_forest(hr)
plot_forest(hr, theme = "modern", colors = "okabe_ito")
```

**Test Conditions**:
```r
test_that("plot_forest returns ggplot object", {
  hr <- estimate(make_data(), score, group, nits = 100)
  p <- plot_forest(hr)
  expect_s3_class(p, "ggplot")
})

test_that("plot_forest shows all groups including control", {
  hr <- estimate(make_data3(), score, sample, nits = 100)
  p <- plot_forest(hr)
  # Should show A, B, C
  expect_equal(length(unique(p$data[[1]])), 3)
})

test_that("plot_forest respects theme and color options", {
  hr <- estimate(make_data(), score, group, nits = 100)
  p <- plot_forest(hr, theme = "modern", colors = "okabe_ito")
  expect_s3_class(p, "ggplot")
})

test_that("forest plot CI bars are correct", {
  set.seed(123)
  hr <- estimate(make_data(), score, group, nits = 100)
  p <- plot_forest(hr)
  # Verify CI values match hr$ci
})
```

**Implementation File**: `R/plot-forest.R` (new file)

---

### Feature 4: Publication Export

**Description**: Save plots with sensible publication defaults (300 DPI, proper dimensions, format options).

**API**:
```r
save_besthr(hr, "figure1.png")  # Auto-detect format from extension
save_besthr(hr, "figure1.pdf", width = 8, height = 6, dpi = 300)
save_besthr(hr, "figure1.tiff", dpi = 600)  # High-res for print
```

**Test Conditions**:
```r
test_that("save_besthr creates file", {
  hr <- estimate(make_data(), score, group, nits = 50)
  tmp <- tempfile(fileext = ".png")
  save_besthr(hr, tmp)
  expect_true(file.exists(tmp))
  unlink(tmp)
})

test_that("save_besthr respects dimensions", {
  hr <- estimate(make_data(), score, group, nits = 50)
  tmp <- tempfile(fileext = ".png")
  save_besthr(hr, tmp, width = 10, height = 8, dpi = 150)
  info <- png::readPNG(tmp, info = TRUE)
  expect_equal(attr(info, "dim")[1], 8 * 150)  # height in pixels
  expect_equal(attr(info, "dim")[2], 10 * 150) # width in pixels
  unlink(tmp)
})

test_that("save_besthr supports multiple formats", {
  hr <- estimate(make_data(), score, group, nits = 50)
  for (ext in c(".png", ".pdf", ".svg")) {
    tmp <- tempfile(fileext = ext)
    expect_no_error(save_besthr(hr, tmp))
    expect_true(file.exists(tmp))
    unlink(tmp)
  }
})
```

**Implementation File**: `R/export.R` (new file)

---

### Feature 5: Summary Table

**Description**: Generate publication-ready results table with mean, CI, n, and effect size.

**API**:
```r
besthr_table(hr)                    # Returns tibble
besthr_table(hr, format = "markdown")  # For README
besthr_table(hr, format = "latex")     # For papers
besthr_table(hr, format = "html")      # For web
```

**Test Conditions**:
```r
test_that("besthr_table returns tibble with required columns", {
  hr <- estimate(make_data(), score, group, nits = 100)
  tbl <- besthr_table(hr)
  expect_s3_class(tbl, "tbl_df")
  expect_true(all(c("group", "n", "mean_rank", "ci_low", "ci_high") %in% names(tbl)))
})

test_that("besthr_table includes effect size for non-control groups", {
  hr <- estimate(make_data(), score, group, control = "A", nits = 100)
  tbl <- besthr_table(hr)
  expect_true("effect_size" %in% names(tbl))
  expect_true(is.na(tbl$effect_size[tbl$group == "A"]))  # Control has no effect size
})

test_that("besthr_table markdown format is valid", {
  hr <- estimate(make_data(), score, group, nits = 100)
  md <- besthr_table(hr, format = "markdown")
  expect_true(grepl("\\|", md))  # Contains pipe characters
  expect_true(grepl("---", md))  # Contains header separator
})

test_that("besthr_table values match hrest object", {
  set.seed(42)
  hr <- estimate(make_data(), score, group, nits = 100)
  tbl <- besthr_table(hr)
  # Verify means match
  expect_equal(tbl$mean_rank[tbl$group == "A"], hr$group_means$mean[hr$group_means$group == "A"])
})
```

**Implementation File**: `R/table.R` (new file)

---

## Development Workflow

### For Each Feature

1. **Create test file first**: `tests/testthat/test-<feature>.R`
2. **Run tests** (should fail): `devtools::test(filter = "<feature>")`
3. **Implement minimum code** to pass tests
4. **Run all tests**: `devtools::test()`
5. **Document**: Add roxygen2 comments, run `devtools::document()`
6. **Update README/vignette** with examples
7. **Commit**: Atomic commit with clear message

### Ralph Loop Statement Template

For automated development iterations:

```
Implement <feature_name> for besthr package.

SUCCESS CONDITION: All tests in test-<feature>.R pass AND devtools::check() has 0 errors.

Steps:
1. Read test file to understand requirements
2. Implement in R/<file>.R
3. Run devtools::test(filter = "<feature>")
4. Fix any failures
5. Run devtools::check()
6. When all pass, output <promise>FEATURE COMPLETE</promise>
```
