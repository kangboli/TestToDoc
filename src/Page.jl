export load_julia_file, as_html

using CommonMark

struct Page
    name::String
    nodes::Vector
end

get_name(p::Page) = p.name
get_nodes(p::Page) = p.nodes

function load_julia_file(filename::String)
    lines = open(filename) do f
        readlines(f)
    end

    seps = findall(l -> startswith(l, "#---"), lines)
    seps = [0, seps..., length(lines) + 1]
    n_blocks = length(seps) - 1

    function load_block(i::Int)
        code_str = join(lines[seps[i]+1:seps[i+1]-1], "\n")
        try
            ast = Meta.parse(code_str)
            is_markdown_node(ast) && return ast
        catch _
        end
        return code_str
    end

    return Page(filename, map(load_block, 1:n_blocks))
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
    return parser
end

to_md_string(node::String) = """<pre><code class="language-julia">$(node)</code></pre>"""
function to_md_string(node::Expr)
    return first(filter(t -> isa(t, String), node.args))
end


function as_html(p::Page)
    parser = make_parser()
    md_page = join(map(to_md_string, get_nodes(p)), "\n")

    ast = parser(md_page)

    return html(ast)
end


purge_line_numbers!(e::Any) = e
function purge_line_numbers!(expr::Expr)
    expr.args = [purge_line_numbers!(a) for a in expr.args if !isa(a, LineNumberNode)]
    return expr
end
