module ReferenceTests

using Test
using Images
using FileIO
using ImageInTerminal
using ColorTypes
using SHA
using DeepDiffs
using Random

export
    @withcolor,
    @io2str,
    @test_reference

include("utils.jl")
include("test_reference.jl")
include("core.jl")
include("handlers.jl")
include("equality_metrics.jl")

end # module
