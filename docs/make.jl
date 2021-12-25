using KiteUtils
using Documenter

DocMeta.setdocmeta!(KiteUtils, :DocTestSetup, :(using KiteUtils); recursive=true)

makedocs(;
    modules=[KiteUtils],
    authors="Uwe Fechner <uwe.fechner.msc@gmail.com> and contributors",
    repo="https://github.com/ufechner7/KiteUtils.jl/blob/{commit}{path}#{line}",
    sitename="KiteUtils.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ufechner7.github.io/KiteUtils.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Exported Functions" => "functions.md",
        "Exported Types" => "types.md",
    ],
)

deploydocs(;
    repo="github.com/ufechner7/KiteUtils.jl",
    devbranch="main",
)
