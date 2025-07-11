# ⚠️ DEPRECATED / ARCHIVED

> **This repository is deprecated and no longer maintained.**

## Why is this deprecated?

MADAME-api has been restructured into the following components as part of the [reefguide](https://github.com/open-AIMS/reefguide) project:

- [ADRIAReefGuideWorker.jl](https://github.com/open-AIMS/ADRIAReefGuideWorker.jl) - the worker node which consumes ADRIA jobs
- [ADRIA.jl](https://github.com/open-AIMS/ADRIA.jl) - the ADRIA.jl library functions

## Need Help?

If you have questions or concerns about this deprecation, please contact the ReefGuide development team.
---

*This notice was added on 11/7/25. The repository will remain accessible for historical reference.*

---

# MADAME-api

Prototype Julia API for [ADRIA.jl](https://github.com/open-AIMS/ADRIA.jl)
using [Oxygen](https://oxygenframework.github.io/Oxygen.jl/stable/).

Used by [MADAME-app](https://github.com/open-AIMS/MADAME-app).

## Setup

`] instantiate`

Edit `LocalPreferences.toml`, set `resultsets_dir` to your ADRIA.jl Outputs (or wherever you have resultsets)

Example:

```toml
resultsets_dir = "<path/to/ADRIA-results-dir>"
```

Create or modify the existing ADRIA `config.toml` file such that ADRIA store new model runs
in the same directory.

```toml
[results]
output_dir = "<path/to/ADRIA-results-dir>"
```

## Running

```julia
using MADAMEAPI

start_server()

# Alternatively, use the development server to see debug messages
# dev_server()
```
