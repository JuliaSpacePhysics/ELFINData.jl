using ELFINData
using Documenter

DocMeta.setdocmeta!(ELFINData, :DocTestSetup, :(using ELFINData); recursive=true)

makedocs(;
    modules=[ELFINData],
    authors="Beforerr <zzj956959688@gmail.com> and contributors",
    sitename="ELFINData.jl",
    format=Documenter.HTML(;
        canonical="https://Beforerr.github.io/ELFINData.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Beforerr/ELFINData.jl",
    devbranch="main",
)
