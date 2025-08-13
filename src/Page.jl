export load_julia_file, as_html

using CommonMark

struct Page
    name::String
    nodes::Vector
    source::String
end

get_name(p::Page) = p.name
get_nodes(p::Page) = p.nodes
get_source(p::Page) = p.source

function load_julia_file(filename::String)
    lines = open(filename) do f
        readlines(f)
    end
    ast = Meta.parse("begin " * join(lines, "\n") * " end")

    seps = map(n -> n.line, filter(a -> isa(a, LineNumberNode), ast.args))
    seps = [seps..., length(lines) + 1]
    n_blocks = length(seps) - 1

    function load_block(i::Int)
        code_str = join(lines[seps[i]:seps[i+1]-1], "\n")
        try
            ast = Meta.parse(code_str)
            is_markdown_node(ast) && return ast
        catch _
        end
        return string(code_str)
    end

    new_blocks = []
    for b in map(load_block, 1:n_blocks)
        if (isempty(new_blocks) || isa(b, Expr) || isa(last(new_blocks), Expr))
            push!(new_blocks, b)
        else
            new_blocks[end] *= "\n$(b)"
        end
    end

    trim(e::Expr) = e
    trim(s::String) = string(strip(s))

    return Page(filename, trim.(new_blocks), join(expand_include(lines, dirname(filename)), "\n"))
end


function is_markdown_node(node::Expr)
    node.head == :macrocall || return false
    return node.args[1] == Symbol("@md_str")
end

function make_parser()
    parser = Parser()
    enable!(parser, MathRule())
    enable!(parser, DollarMathRule())
    enable!(parser, AttributeRule())
    enable!(parser, AutoIdentifierRule())
    enable!(parser, TableRule())
    return parser
end

to_md_string(node::String) = """
    <pre><code class="language-julia">$(node)</code><div><p></p><button>copy</button></div></pre>
    """
function to_md_string(node::Expr)
    return first(filter(t -> isa(t, String), node.args))
end


function as_html(p::Page)
    parser = make_parser()
    md_page = join(map(to_md_string, get_nodes(p)), "\n")

    ast = parser(md_page)

    return html(ast)
end

function find_include(lines, dir)
    for (i, l) in enumerate(lines)
        m = match(r"include\((.+)\)", l)
        m === nothing && continue
        file_path = eval(Meta.parse(first(m.captures)))
        isabspath(file_path) && return (i, file_path)
        return (i, joinpath(dir, file_path))
    end
    return length(lines), nothing
end

function expand_include(lines, dir)
    line_number, file = find_include(lines, dir)
    file === nothing && return lines
    return expand_include(
        [lines[1:line_number-1]...,
            readlines(file)...,
            lines[line_number+1:end]...], dir)
end
