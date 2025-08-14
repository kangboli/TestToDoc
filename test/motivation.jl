md"""
`TestToDoc.jl` generates documentation from tests without running them.
It helps you build userguides that is easy to read and navigate
from tests without invading the test system.

The main use case is to build a practical e-book (for computational physical
science) from a set of self-contained tests. Compared to a traditional textbook,
the advantages are

| | e-book | paperback |
|:--|:---|:---|
| code | every pages is self-contained and runnable | theory to practice is almost infeasible |
| distribution | all content reachable from search engines | only title & abstract are accessible |
| growth | continuously updatable | immutable after publication |

## Compared to Alternatives

There are few other technologies that can do similar things, but they don't
really fit the bill for our purposes.


| | Pluto | Documenter| TestToDoc |
|:--|:-----:|:---------:|:-----------:|
| self-contained tutorial |  $\checkmark$    | $\times$|  $\checkmark$ |
| navigatable documentation | $\times$ | $\checkmark$ | $\checkmark$ |
| avoid constraining tests | $\times$ | $\times$ | $\checkmark$ |
"""
