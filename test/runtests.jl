using TestToDoc

filepaths = [
    "test/cover.jl",
    "test/motivation.jl",
    "test/quickstart.jl",
    "test/design/theme.jl",
    "test/design/dependencies.jl",
    "test/example.md",
]
watch!(filepaths; src="./test", port=8889)
