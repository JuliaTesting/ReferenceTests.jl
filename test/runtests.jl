using Test
using ImageInTerminal, TestImages, ImageCore, ImageTransformations
using Random

if isinteractive()
    @info ("In interactive use, one should respond \"n\" when the program"
           * " offers to create or replace files associated with some tests.")
else
    @info ("Ten tests should correctly report failure in the transcript"
           * " (but not the test summary).")
end
# check for ambiguities
refambs = detect_ambiguities(ImageInTerminal, Base, Core)

using ReferenceTests
ambs = detect_ambiguities(ReferenceTests, ImageInTerminal, Base, Core)

@testset "ReferenceTests" begin

@test Set(setdiff(ambs, refambs)) == Set{Tuple{Method,Method}}()

# load/create some example images
lena = testimage("lena_color_256")
camera = testimage("cameraman")
cameras = similar(camera, size(camera)..., 2)
copyto!(view(cameras,:,:,1), camera)
copyto!(view(cameras,:,:,2), camera)
square = Gray{N0f8}[0.1 0.2 0.3; 0.4 0.5 0.6; 0.7 0.6 0.9]
rgb_rect = rand(RGB{N0f8}, 2, 3)

@testset "io2str" begin
    @test_throws LoadError eval(@macroexpand @io2str(::IO))
    @test_throws ArgumentError @io2str(2)
    @test_throws ArgumentError @io2str(string(2))
    @test @io2str(print(::IO, "foo")) == "foo"
    @test @io2str(println(::IO, "foo")) == "foo\n"
    @test @io2str(show(::IO, "foo")) == "\"foo\""
    A = ones(30,30)
    @test @io2str(show(IOContext(::IO, :limit => true, :displaysize => (5,5)), A)) == "[1.0 1.0 … 1.0 1.0; 1.0 1.0 … 1.0 1.0; … ; 1.0 1.0 … 1.0 1.0; 1.0 1.0 … 1.0 1.0]"
end

@testset "withcolor" begin
    @test_throws ArgumentError @withcolor throw(ArgumentError("foo"))
    @test @withcolor Base.have_color == true
    @test @withcolor @io2str(printstyled(IOContext(::IO, :color => true), "test", color=:green)) == "\e[32mtest\e[39m"
end

@testset "string as txt" begin
    foo = "foo"
    @test_reference "references/string1.txt" foo * "bar"
    @test_reference "references/string1.txt" [foo * "bar"]
    A = ones(30,30)
    @test_reference "references/string2.txt" @io2str show(IOContext(::IO, :limit=>true, :displaysize=>(5,5)), A)
    @test_reference "references/string3.txt" 1337
    @test_reference "references/string3.txt" 1338 by=(ref, x)->isapprox(ref, x; atol=10)
    @test_reference "references/string4.txt" @io2str show(::IO, MIME"text/plain"(), Int64.(collect(1:5)))

    @test_reference "references/string5.txt" """
        This is a
        multiline string that does not end with a new line."""

    @test_reference "references/string6.txt" """
        This on the other hand is a
        multiline string that does indeed end with a new line.
    """

    @test_throws ErrorException @test_reference "references/string1.txt" "intentionally wrong to check that this message prints"
    @test_throws ErrorException @test_reference "references/string5.txt" """
        This is an incorrect
        multiline string that does not end with a new line."""
end

@testset "string as unknown file type" begin
    @test_reference "references/string1.nottxt" "This is not a .txt file, but it should be treated as such.\n"
end

@testset "images as txt using ImageInTerminal" begin
    #@test_throws MethodError @test_reference "references/fail.txt" rand(2,2)

    @test_reference "references/camera.txt" camera size=(5,10)
    @test_reference "references/lena.txt" lena
end

@testset "plain ansi string" begin
    @test_reference(
        "references/ansii.txt",
        @io2str(printstyled(IOContext(::IO, :color=>true), "this should be blue", color=:blue)),
        render = ReferenceTests.BeforeAfterFull()
    )
    @test_throws ErrorException @test_reference(
        "references/ansii.txt",
        @io2str(printstyled(IOContext(::IO, :color=>true), "this should be red", color=:red)),
        render = ReferenceTests.BeforeAfterFull()
    )
end

@testset "string as SHA" begin
    @test_reference "references/number1.sha256" 1337
    foo = "foo"
    @test_reference "references/string1.sha256" foo * "bar"
    A = ones(30,30)
    @test_reference "references/string2.sha256" @io2str show(IOContext(::IO, :limit=>true, :displaysize=>(5,5)), A)
end

@testset "images as SHA" begin
    @test_reference "references/camera.sha256" camera
    @test_reference "references/lena.sha256" convert(Matrix{RGB{Float64}}, lena)
end

@testset "images as PNG" begin
    @test_reference "references/camera.png" imresize(camera, (64,64))
    @test_reference "references/camera.png" imresize(camera, (64,64)) by=psnr_equality(25)
    @test_throws ErrorException @test_reference "references/camera.png" imresize(lena, (64,64))
    @test_throws Exception @test_reference "references/camera.png" camera # unequal size
end

using DataFrames, CSVFiles
@testset "DataFrame as CSV" begin
    @test_reference "references/dataframe.csv" DataFrame(v1=[1,2,3], v2=["a","b","c"])
    @test_throws ErrorException @test_reference "references/dataframe.csv" DataFrame(v1=[1,2,3], v2=["c","b","c"])

end

@testset "Create new $ext" for (ext, val) in (
    (".csv", DataFrame(v1=[1,2,3], v2=["c","b","c"])),
    (".png", imresize(camera, (64,64))),
    (".txt", "Lorem ipsum dolor sit amet, labore et dolore magna aliqua."),
)
    newfilename = "references/newfilename.$ext"
    @assert !isfile(newfilename)
    @test_reference newfilename val  # this should create it
    @test isfile(newfilename)  # Was created
    @test_reference newfilename val  # Matches expected content
    rm(newfilename, force=true)
end

@testset "Create new image as txt" begin
    # This is a sperate testset as need to use the `size` argument to ``@test_reference`
    newfilename = "references/new_camera.txt"
    @assert !isfile(newfilename)
    @test_reference newfilename camera size=(5,10)  # this should create it
    @test isfile(newfilename)  # Was created
    @test_reference newfilename camera size=(5,10) # Matches expected content
    rm(newfilename, force=true)
end

end  # top level testset
