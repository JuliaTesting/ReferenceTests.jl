type_files = [
    "string.jl",
    "image.jl",
    "number_array.jl",
    "dataframe.jl"
]

for file in type_files
    type = first(splitext(file))
    @testset "Type: $type" begin
        include(joinpath("types", file))
    end
end

# TODO: split this testset into previous files
@testset "Reference regeneration" begin
    camera = testimage("cameraman")

    @testset "Create new $ext" for (ext, val) in (
        (".csv", DataFrame(v1=[1,2,3], v2=["c","b","c"])),
        (".png", imresize(camera, (64,64))),
        (".txt", "Lorem ipsum dolor sit amet, labore et dolore magna aliqua."),
    )
        newfilename = joinpath(refroot, "newfilename.$ext")
        @assert !isfile(newfilename)
        @test_reference newfilename val  # this should create it
        @test isfile(newfilename)  # Was created
        @test_reference newfilename val  # Matches expected content
        rm(newfilename, force=true)
    end

    @testset "Create new image as txt" begin
        # This is a sperate testset as need to use the `size` argument to ``@test_reference`
        newfilename = joinpath(refroot, "new_camera.txt")
        @assert !isfile(newfilename)
        @test_reference newfilename camera size=(5,10)  # this should create it
        @test isfile(newfilename)  # Was created
        @test_reference newfilename camera size=(5,10) # Matches expected content
        rm(newfilename, force=true)
    end
end
