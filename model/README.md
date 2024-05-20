# IESopt Model Configuration

Consult the following parts of the model:
- `opt/templates/` for the custom `Template`s that were defined
- `opt/addons/` for the custom `Addon`s that were defined (some showcasing functionality that is inside the core model)
- `opt/config.iesopt.yaml` for the main config file (and `global.iesoptparam.yaml` for the used parameters)

## Executing the model

Assuming a successful setup of `IESopt`:

```python
# Using Python
import pymf

model = pymf.run("opt/config.iesopt.yaml", methane_substitution=68150.9*0.10, el_type="PEMEL")
```

```julia
# Using Julia
using IESopt

model = generate!("opt/config.iesopt.yaml"; methane_substitution=68150.9*0.10, el_type="PEMEL")
optimize!(model)
```
