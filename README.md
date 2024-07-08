# MADAME-api

Prototype Julia API for [ADRIA.jl](https://github.com/open-AIMS/ADRIA.jl)
using [Oxygen](https://oxygenframework.github.io/Oxygen.jl/stable/).

Used by [MADAME-app](https://github.com/open-AIMS/MADAME-app).

## Setup

`] instantiate`

Edit `LocalPreferences.toml`, set `resultsets_dir` to your ADRIA.jl Outputs (or wherever you have resultsets)

Example:
```
resultsets_dir = "C:\\Users\\awhite\\code\\ADRIA.jl\\sandbox\\Outputs"
```

## Running

Run `src/main.jl`
