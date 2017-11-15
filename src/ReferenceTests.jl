module ReferenceTests

using Images
using FileIO
using ImageInTerminal
using ColorTypes
using SHA

using Base.Test
import Base.Test: record, finish
using Base.Test: DefaultTestSet, AbstractTestSet
using Base.Test: get_testset_depth, scrub_backtrace, get_testset
using Base.Test: Result, Pass, Fail, Error


export
    ReferenceTestSet,
    @withcolor,
    @io2str,
    @test_reference

include("testset.jl")
include("utils.jl")
include("test_reference.jl")
include("string.jl")
include("fallback.jl")

end # module
