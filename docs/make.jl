using MindReader
using Documenter

DocMeta.setdocmeta!(MindReader, :DocTestSetup, :(using MindReader); recursive=true)

makedocs(;
    modules=[MindReader],
    authors="DanielRivasMD <danielrivasmd@gmail.com> and contributors",
    repo="https://github.com/DanielRivasMD/MindReader.jl/blob/{commit}{path}#{line}",
    sitename="MindReader.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://DanielRivasMD.github.io/MindReader.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/DanielRivasMD/MindReader.jl",
)
