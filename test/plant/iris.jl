md"""
## IRIS dataset

This tutorial guides you through a linear regression on the /Iris/ dataset.
```math
\mathbf{A} \mathbf{x} = \mathbf{b}
```
"""

#----

function iris_regression(A, b)
    return A \ b
end
