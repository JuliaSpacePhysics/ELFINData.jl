using ELFINData
using Documenter
using Bonito

let readme = read(joinpath(@__DIR__, "..", "README.md"), String)
    write(joinpath(@__DIR__, "src", "index.md"), readme)
end

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
        "Examples" => "examples.md",
        "Validation and Benchmark" => "validation.md",
    ],
    checkdocs = :none
)

deploydocs(;
    repo = "github.com/JuliaSpacePhysics/ELFINData.jl",
    push_preview = true
)
