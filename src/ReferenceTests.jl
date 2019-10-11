module ReferenceTests

using Test
using ImageCore
using Distances
using FileIO
using ImageInTerminal
using SHA
using DeepDiffs
using Random

export
    @withcolor,
    @io2str,
    @test_reference,
    @test_reference_broken,
    psnr_equality

include("utils.jl")
include("test_reference.jl")
include("test_reference_broken.jl")
include("fileio.jl")
include("equality_metrics.jl")
include("render.jl")

end # module
