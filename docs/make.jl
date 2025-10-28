using ELFINData
using Documenter

DocMeta.setdocmeta!(ELFINData, :DocTestSetup, :(using ELFINData); recursive = true)

makedocs(;
    modules = [ELFINData],
    authors = "Beforerr <zzj956959688@gmail.com> and contributors",
    sitename = "ELFINData.jl",
    format = Documenter.HTML(;
        canonical = "https://JuliaSpacePhysics.github.io/ELFINData.jl",
    ),
    pages = [
        "Home" => "index.md",
    ],
    checkdocs = :exports
)

deploydocs(;
    repo = "github.com/JuliaSpacePhysics/ELFINData.jl",
    push_preview = true
)
