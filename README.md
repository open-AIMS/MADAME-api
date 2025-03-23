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
