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
| `R/functions.R` | All core logic: estimate, plot, print, helpers |
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
