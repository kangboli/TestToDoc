
md"""
You can customize the theme by overwriting `TestToDoc.page_css()`.
For example, 

"""

function TestToDoc.page_css()
    return """
    p {
        color: white;
    }
    """
end
