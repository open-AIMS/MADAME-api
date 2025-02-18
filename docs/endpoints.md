## Invokeing Model Runs

```julia
    @post "/invoke-run/coralblox" function (req)
```

Endpoint to allow the end user to invoke model runs. The request body should be json of the 
following form.

```json
{
  "run_name": <run_name>,
  "num_scenarios": <num_scenarios>,
  "model_params": [
    {
      "param_name": name,
      "third_param_flag": <Boolean>,
      "lower": <lower>,
      "upper": <upper>,
      "optional_third": 
    },
    ...
  ]
}
```
"""

