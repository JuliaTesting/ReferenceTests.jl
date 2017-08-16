using ImageInTerminal, Images, TestImages, Base.Test, ColorTypes, FixedPointNumbers

# check for ambiguities
refambs = detect_ambiguities(ImageInTerminal, Base, Core)
using ReferenceTests
ambs = detect_ambiguities(ReferenceTests, ImageInTerminal, Base, Core)
@test length(setdiff(ambs, refambs)) == 0

# load/create some example images
lena = testimage("lena_color_256")
camera = testimage("cameraman")
cameras = similar(camera, size(camera)..., 2)
copy!(view(cameras,:,:,1), camera)
copy!(view(cameras,:,:,2), camera)
square = Gray{N0f8}[0.1 0.2 0.3; 0.4 0.5 0.6; 0.7 0.6 0.9]
rgb_rect = rand(RGB{N0f8}, 2, 3)

@testset "io2str" begin
    @test_throws ArgumentError eval(@macroexpand @io2str(::IO))
    @test @io2str(2) == 2
    @test @io2str(string(2)) == "2"
    @test @io2str(print(::IO, "foo")) == "foo"
    @test @io2str(println(::IO, "foo")) == "foo\n"
    @test @io2str(show(::IO, "foo")) == "\"foo\""
    A = ones(30,30)
    @test @io2str(show(IOContext(::IO, limit=true, displaysize=(5,5)), A)) == "[1.0 1.0 … 1.0 1.0; 1.0 1.0 … 1.0 1.0; … ; 1.0 1.0 … 1.0 1.0; 1.0 1.0 … 1.0 1.0]"
end

@testset "string as txt" begin
    foo = "foo"
    @test_reference "references/string1.txt" foo * "bar"
    @test_reference "references/string1.txt" [foo * "bar"]
    A = ones(30,30)
    @test_reference "references/string2.txt" @io2str show(IOContext(::IO, limit=true, displaysize=(5,5)), A)
end

@testset "images as txt using ImageInTerminal" begin
    #@test_throws MethodError @test_reference "references/fail.txt" rand(2,2)
    @test_reference "references/camera.txt" camera size=(5,10)
    @test_reference "references/lena.txt" lena
end

@testset "string as SHA" begin
    foo = "foo"
    @test_reference "references/string1.sha256" foo * "bar"
    A = ones(30,30)
    @test_reference "references/string2.sha256" @io2str show(IOContext(::IO, limit=true, displaysize=(5,5)), A)
end

@testset "images as SHA" begin
    @test_reference "references/camera.sha256" camera
    @test_reference "references/lena.sha256" convert(Matrix{RGB{Float64}}, lena)
end

@test_reference "references/camera.png" imresize(camera, (64,64))
# @test_reference "img1.txt" rand(RGB, 10, 10)

# @test_reference "rand.csv" DataTable(v1=[1,2,3], v2=["a","b","c"])
