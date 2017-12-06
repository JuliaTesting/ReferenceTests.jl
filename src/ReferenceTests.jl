module ReferenceTests

using Images
using FileIO
using ImageInTerminal
using ColorTypes
using SHA

using Base.Test
using Base.Test: record, get_testset, Result, Pass, Fail, Error


export
    @withcolor,
    @io2str,
    @test_reference

include("testset.jl")
include("utils.jl")
include("test_reference.jl")
include("string.jl")
include("fallback.jl")

end # module
