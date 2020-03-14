module ReferenceTests

using Test
using ImageCore
using Distances
using FileIO
using ImageInTerminal
using SHA
using DeepDiffs
using Random
using MosaicViews
using ImageShow

export
    @withcolor,
    @io2str,
    @test_reference,
    psnr_equality

include("utils.jl")
include("test_reference.jl")
include("fileio.jl")
include("equality_metrics.jl")
include("render.jl")

end # module
