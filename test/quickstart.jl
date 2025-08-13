md"""

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

Math is supported by `KaTeX`. For example

$$
\begin{equation}
i \hbar \frac{d}{dt} \Psi = H \Psi
\end{equation}
$$

`Copy-tex` is enabled so copying it puts the tex code in your clipboard.

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
