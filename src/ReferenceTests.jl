module ReferenceTests

using LazyModules

using Test
using Colors
using Distances
using FileIO
@lazy import ImageCore = "a09fc81d-aa75-5fe9-8630-4744c3626534"
@lazy import XTermColors = "c8c2cc18-de81-4e68-b407-38a3a0c0491f"
using SHA
using DeepDiffs
using Random

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

if Base.VERSION >= v"1.4.2" && ccall(:jl_generating_output, Cint, ()) == 1
    precompile(Tuple{Core.kwftype(typeof(test_reference)),NamedTuple{(:by,), Tuple{typeof(isequal)}},typeof(test_reference),String,Matrix{RGB{Float64}}})  || @warn "Failure to precompile ReferenceTests.test_reference(String,Matrix{RGB})"
    precompile(Tuple{Core.kwftype(typeof(test_reference)),NamedTuple{(:by,), Tuple{typeof(isequal)}},typeof(test_reference),String,Matrix{RGBA{Float64}}}) || @warn "Failure to precompile ReferenceTests.test_reference(String,Matrix{RGBA})"
    if isdefined(FileIO, :action)
        precompile(Tuple{typeof(test_reference),File{DataFormat{:PNG},String},Matrix{RGB{Float64}},Function,Nothing})  || @warn "Failure to precompile ReferenceTests.test_reference(File{format\"PNG\",String},Matrix{RGB})"
        precompile(Tuple{typeof(test_reference),File{DataFormat{:PNG},String},Matrix{RGBA{Float64}},Function,Nothing}) || @warn "Failure to precompile ReferenceTests.test_reference(File{format\"PNG\",String},Matrix{RGBA})"
    else
        precompile(Tuple{typeof(test_reference),File{DataFormat{:PNG}},Matrix{RGB{Float64}},Function,Nothing})  || @warn "Failure to precompile ReferenceTests.test_reference(File{format\"PNG\"},Matrix{RGB})"
        precompile(Tuple{typeof(test_reference),File{DataFormat{:PNG}},Matrix{RGBA{Float64}},Function,Nothing}) || @warn "Failure to precompile ReferenceTests.test_reference(File{format\"PNG\"},Matrix{RGBA})"
    end
end

end # module
