using Documenter, ReferenceTests

format = Documenter.HTML(edit_link = "master",
                         prettyurls = get(ENV, "CI", nothing) == "true")

makedocs(
    format = format,
    modules = [ReferenceTests],
    sitename = "ReferenceTests.jl",
    authors = "Christof Stocker",
    linkcheck = !("skiplinks" in ARGS),
    checkdocs = :exports,
    pages = Any[
        "Home" => "index.md",
    ]
)

deploydocs(repo = "github.com/JuliaTesting/ReferenceTests.jl.git")
