module ReferenceTests

using Test
using ImageCore
using Distances
using FileIO
using PNGFiles
using ImageInTerminal
using SHA
using DeepDiffs
using Random

export
    @withcolor,
    @io2str,
    @test_reference,
    @test_reference_plot,
    psnr_equality

include("utils.jl")
include("test_reference.jl")
include("test_reference_plot.jl")
include("fileio.jl")
include("equality_metrics.jl")
include("render.jl")

if Base.VERSION >= v"1.4.2" && ccall(:jl_generating_output, Cint, ()) == 1
    @assert precompile(Tuple{Core.kwftype(typeof(test_reference)),NamedTuple{(:by,), Tuple{typeof(isequal)}},typeof(test_reference),String,Matrix{RGB{Float64}}})   # time: 0.4697069
    @assert precompile(Tuple{Core.kwftype(typeof(test_reference)),NamedTuple{(:by,), Tuple{typeof(isequal)}},typeof(test_reference),String,Matrix{RGBA{Float64}}})   # time: 0.24671553
    @assert precompile(Tuple{typeof(test_reference),File{DataFormat{:PNG}},Matrix{RGB{Float64}},Function,Nothing})   # time: 0.029915236
    @assert precompile(Tuple{typeof(test_reference),File{DataFormat{:PNG}},Matrix{RGBA{Float64}},Function,Nothing})   # time: 0.013356352
end

end # module
