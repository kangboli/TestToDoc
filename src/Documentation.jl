export Documentation, load_files, gen_doc!, watch!

using BetterFileWatching, LiveServer

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
    sources = map(get_source, get_pages(d))
    get_id(title::String) = replace(title, '/' => '-')


    content = join(["""
        <details style="margin: 1em 0em">
        <summary><span class="page" id="$(get_id(t))">$(
        uppercasefirst(t[1:end-3])
    )</span></summary>
        <pre><code class="language-julia">$(s)</code><div><p></p><button>copy</button></div></pre></details>
        \n$(h)""" for (t,s, h) in zip(titles, sources, htmls)])
    #= content = join(["<h1>$(get_name(p))</h1>\n$(as_html(p))"
        for [ in get_pages(d)], "\n") =#
    toc = ["""<a href="#$(get_id(t))">$(t[1:end-3])</a>""" for t in titles]

    return """
<!DOCTYPE html>
<html>
<head>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Geist+Mono:wght@100..900&family=Geist:wght@100..900&display=swap" rel="stylesheet">

 <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.22/dist/katex.min.css" integrity="sha384-5TcZemv2l/9On385z///+d7MSYlvIEw9FuZTIdZ14vJLqWphw7e7ZPuOiCHJcFCP" crossorigin="anonymous">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.22/dist/katex.min.js" integrity="sha384-cMkvdD8LoxVzGF/RPUKAcvmm49FQ0oxwDF3BGKtDXcEc+T1b2N+teh/OJfpU0jr6" crossorigin="anonymous"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.22/dist/contrib/auto-render.min.js" integrity="sha384-hCXGrW6PitJEwbkoStFjeJxv+fSOOQKOPbJxSfM6G5sWZjAyWhXiTIIAmQqnlLlh" crossorigin="anonymous"
        onload="renderMathInElement(document.body);"></script>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/sunburst.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js"></script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/julia.min.js"></script>

<script>hljs.highlightAll();</script>
<style>
    $(page_css())
</style>
<script>
function clip() {
    let blocks = document.querySelectorAll("pre:has(code)");
    blocks.forEach((block) => {
      let button = block.querySelector("div button");

      // handle click event
      button.addEventListener("click", async () => {
        await copyCode(block);
      });
    });
}

async function copyCode(block) {
  let code = block.querySelector("code");
  let text = code.innerText;

  await navigator.clipboard.writeText(text);
}
</script>
</head>
    <body onload="clip();">
    <div class="toc">
    <image style="margin: 10px 20px;"
    width="120px" src="/assets/logo.png">
    </image>
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

function watch!(filepaths::Vector{String}, src="./test", dst="./doc")
    gen_doc!(filepaths, dst)
    try
        @sync begin
            Threads.@spawn while true
                watch_folder((event) -> gen_doc!(filepaths, dst), src)
            end
            Threads.@spawn serve(dir=dst, port=8080)
            println("http://localhost:8080/index.html")
        end
    catch ex
        isa(ex, InterruptException) && println("I'm done; you've been great; bye.")
        return
    end
end

