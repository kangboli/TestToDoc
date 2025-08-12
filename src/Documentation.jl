export Documentation, load_files, gen_doc!

struct Documentation
    pages::Vector{Page}
end

get_pages(d::Documentation) = d.pages

function load_files(filepaths::Vector{String})
    pages = map(load_julia_file, filepaths)
    return Documentation(pages)
end

function page_css()
    css_path = join([split(pathof(TestToDoc), "/")[1:end-1]..., "doc.css"], "/")
    css = open(css_path) do f
        join(readlines(f), "\n")
    end
    return css
end

function as_html(d::Documentation)
    titles = map(t -> join(split(get_name(t), "/")[2:end], "/"), get_pages(d))
    htmls = map(as_html, get_pages(d))
    get_id(title::String) = replace(title, '/' => '-')


    content = join(["""<h1 id="$(get_id(t))">$(
        t[1:end-3]
    )</h1>\n$(h)""" for (t, h) in zip(titles, htmls)])
    #= content = join(["<h1>$(get_name(p))</h1>\n$(as_html(p))"
        for [ in get_pages(d)], "\n") =#
    toc = ["""<a href="#$(get_id(t))">$(t[1:end-3])</a>""" for t in titles]

    return """
<!DOCTYPE html>
<html>
<head>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Courier+Prime:ital,wght@0,400;0,700;1,400;1,700&family=STIX+Two+Text:ital,wght@0,400..700;1,400..700&display=swap" rel="stylesheet">

 <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.22/dist/katex.min.css" integrity="sha384-5TcZemv2l/9On385z///+d7MSYlvIEw9FuZTIdZ14vJLqWphw7e7ZPuOiCHJcFCP" crossorigin="anonymous">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.22/dist/katex.min.js" integrity="sha384-cMkvdD8LoxVzGF/RPUKAcvmm49FQ0oxwDF3BGKtDXcEc+T1b2N+teh/OJfpU0jr6" crossorigin="anonymous"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.22/dist/contrib/auto-render.min.js" integrity="sha384-hCXGrW6PitJEwbkoStFjeJxv+fSOOQKOPbJxSfM6G5sWZjAyWhXiTIIAmQqnlLlh" crossorigin="anonymous"
        onload="renderMathInElement(document.body);"></script>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/panda-syntax-dark.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js"></script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/julia.min.js"></script>

<script>hljs.highlightAll();</script>
<style>
    $(page_css())
</style>
</head>
<body>
    <div class="toc">
    $(join(toc, "\n"))
    </div>
    <div class="main">
$(content)
    </div>
</body>
</html>
    """
end


function gen_doc!(filepaths::Vector{String}, dst="./doc")
    out = open("$(dst)/index.html", "w")
    write(out, as_html(load_files(filepaths)))
    close(out)
end
