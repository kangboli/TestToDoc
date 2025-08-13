md"""
## Motivation

`TestToDoc.jl` generates documentation from tests without running them.
It helps you build userguides that is easy to read and navigate
from tests without invading the test system.

## Alternatives

1. Pluto.jl:
    1. great for tutorials.
    2. evaluation rules too strict for tests.
    3. hard to navigate many notebooks in html form.
2. Documenter.jl:
    1. easy to navigate and search.
    2. `doctests` are hard to debug, profile, or selectively run.
    3. no live preview.

## Usage

Make a list of tests that are to be converted to userguides.
Use `watch` to live preview the files.
"""
using DocToTests

filepaths = [
    "test/quickstart.jl",
    "test/design/theme.jl"
]

watch!(filepaths, "./test")

md"""
The order in which these files are passed 
determines the order they show up the this page.

## Syntax

You can write markdown blocks
```julia
md"
text/math goes here
"
```
It  will just parsed with `CommonMark.jl` and converted to html.
Julia code will be converted to code blocks.

## Structure

The structure of this page will mirror the file system structure 
of the tests. The tests of this package is organized as 
```txt
test
├── design
│   └── theme.jl
├── quickstart.jl
└── runtests.jl
```
"""


