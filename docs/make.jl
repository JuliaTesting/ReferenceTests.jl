using Documenter, ReferenceTests

makedocs(
    modules = [ReferenceTests],
    clean = false,
    format = :html,
    sitename = "ReferenceTests.jl",
    authors = "Christof Stocker",
    linkcheck = !("skiplinks" in ARGS),
    pages = Any[
        "Home" => "index.md",
    ],
    html_prettyurls = !("local" in ARGS),
)

deploydocs(
    repo = "github.com/Evizero/ReferenceTests.jl.git",
    target = "build",
    julia = "1.0",
    deps = nothing,
    make = nothing,
)
