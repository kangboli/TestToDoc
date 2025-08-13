using TestToDoc

filepaths = ["test/example.jl", "test/plant/iris.jl"]
watch!(filepaths, "./test")
