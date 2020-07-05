# load/create some example images
refdir = joinpath(refroot, "image")

lena = testimage("lena_color_256")
camera = testimage("cameraman")
cameras = similar(camera, size(camera)..., 2)
copyto!(view(cameras,:,:,1), camera)
copyto!(view(cameras,:,:,2), camera)
square = Gray{N0f8}[0.1 0.2 0.3; 0.4 0.5 0.6; 0.7 0.6 0.9]
rgb_rect = rand(RGB{N0f8}, 2, 3)

@testset "images as txt using ImageInTerminal" begin
    #@test_throws MethodError @test_reference "references/fail.txt" rand(2,2)

    @test_reference joinpath(refdir, "camera.txt") camera size=(5,10)
    @test_reference joinpath(refdir, "lena.txt") lena
end

@testset "images as SHA" begin
    @test_reference joinpath(refdir, "camera.sha256") camera
    @test_reference joinpath(refdir, "lena.sha256") convert(Matrix{RGB{Float64}}, lena)
end

@testset "images as PNG" begin
    @test_reference joinpath(refdir, "camera.png") imresize(camera, (64,64))
    @test_reference joinpath(refdir, "camera.png") imresize(camera, (64,64)) by=psnr_equality(25)
    @test_throws ErrorException @test_reference joinpath(refdir, "camera.png") imresize(lena, (64,64))
    @test_throws Exception @test_reference joinpath(refdir, "camera.png") camera # unequal size
end
