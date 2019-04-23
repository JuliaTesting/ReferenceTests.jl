module ReferenceTests

using Test
using Random
using SHA

using FileIO
using DeepDiffs
using Requires

export
    @withcolor,
    @io2str,
    @test_reference

include("utils.jl")
include("test_reference.jl")
include("core.jl")

# handlers with no heavy requirements
include("handlers/general.jl")
include("handlers/text.jl")

function __init__()
    # images type
    @require ColorTypes="3da002f7-5984-5a60-b8a6-cbb66c0b333f" include("handlers/image.jl")
    @require Colors="5ae59095-9a9b-59fe-a467-6f913c188581" include("handlers/image.jl")
    @require ImageCore="a09fc81d-aa75-5fe9-8630-4744c3626534" include("handlers/image.jl")
    @require ImageInTerminal="d8c32880-2388-543b-8c61-d9f865259254" include("handlers/image.jl")
    @require Images="916415d5-f1e6-5110-898d-aaa5f9f070e0" include("handlers/image.jl")
    @require TestImages="5e47fb64-e119-507b-a336-dd2b206d9990" include("handlers/image.jl")
end

end # module
