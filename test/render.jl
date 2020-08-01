using ReferenceTests: Diff, BeforeAfterFull, BeforeAfterImage, BeforeAfterLimited
using ReferenceTests: render, render_item

refdir = joinpath(refroot, "render")

@testset "rendermode" begin
    gray_1d = Gray{N0f8}.(0.0:0.1:0.9)
    rgb_1d = RGB.(gray_1d)
    gray_2d = Gray{N0f8}.(reshape(0.0:0.1:0.9, 2, 5))
    rgb_2d = RGB.(gray_2d)

    df = DataFrame(v1=[1,2,3], v2=["a","b","c"])

    check_types = [
        # text types
        ("string", Diff()),
        (["string", "array"], Diff()),

        # number types
        (1, BeforeAfterFull()),
        (1.0im, BeforeAfterFull()),
        ([1 2], BeforeAfterLimited()),
        ([1,2], BeforeAfterLimited()),

        # image types
        (gray_1d, BeforeAfterImage()),
        (rgb_2d, BeforeAfterImage()),

        # dataframe types
        (df, BeforeAfterLimited()),
    ]

    for (x, mode) in check_types
        # @info "Types" data=typeof(x)
        @test ReferenceTests.default_rendermode(typeof(x)) == mode
    end

end

# `render_item` is repeatly called by `render` so we can skip it
@testset "render" begin
    num1 = [1, 2]

    arr1 = [reshape(collect(1:8), 2, 4), reshape(collect(1:8), 1, 8)]
    arr2 = [collect(1:2:20), collect(1:3:20)]
    arr3 = [ones(20, 20), ones(20, 20)]

    str1 = ["Hello world", "hello World"]
    str2 = string.(arr2)
    str3 = string.(arr3)

    img1d_1 = [Gray{N0f8}.(0.0:0.1:0.9), Gray{N0f8}.(0.9:-0.1:0.0)] # different content
    img1d_2 = [Gray{N0f8}.(0.0:0.1:0.9), Gray{N0f8}.(0.0:0.05:0.95)] # different size
    img1d_3 = [Gray{N0f8}.(0.0:0.1:0.9), RGB.(Gray{N0f8}.(0.0:0.1:0.9))] # different colorant
    img2d_1 = [Gray{N0f8}.(reshape(0.0:0.1:0.9, 2, 5)), Gray{N0f8}.(reshape(0.9:-0.1:0.0, 2, 5))]
    img3d_1 = [Gray{N0f8}.(reshape(0.0:0.02:0.95, 2, 4, 6)), Gray{N0f8}.(reshape(0.95:-0.02:0.00, 2, 4, 6))]

    df1 = [DataFrame(v1=[1,2,3], v2=["a","b","c"]), DataFrame(v2=[1,2,3], v1=["a","b","c"])]
    items = [
        # numbers
        (num1, "num1"),
        (arr1, "arr1"),
        (arr2, "arr2"),
        (arr3, "arr3"),
        # strings (hashes are also strings)
        (str1, "str1"),
        (str2, "str2"),
        (str3, "str3"),
        # images
        (img1d_1, "img1d_1"),
        (img1d_2, "img1d_2"),
        (img1d_3, "img1d_3"),
        (img2d_1, "img2d_1"),
        (img3d_1, "img3d_1"),
        # dataframe
        (df1, "dataframe1"),
    ]
    
    @testset "BeforeAfterFull" begin
        mode = BeforeAfterFull()
        for (x, xname) in items
            # @info "Types" x=typeof(x) mode=mode
            @test_reference joinpath(refdir, "BeforeAfterFull", "$(xname)_new.txt") @io2str(render(::IO, mode, x[2])) by=string_check
            @test_reference joinpath(refdir, "BeforeAfterFull", "$(xname)_compare.txt") @io2str(render(::IO, mode, x...)) by=string_check
        end
    end

    @testset "BeforeAfterLimited" begin
        mode = BeforeAfterLimited()
        for (x, xname) in items
            # @info "Types" x=typeof(x) mode=mode
            @test_reference joinpath(refdir, "BeforeAfterLimited", "$(xname)_new.txt") @io2str(render(::IO, mode, x[2])) by=string_check
            @test_reference joinpath(refdir, "BeforeAfterLimited", "$(xname)_compare.txt") @io2str(render(::IO, mode, x...)) by=string_check
        end
    end

    @testset "Diff" begin
        mode = Diff()
        for (x, xname) in (
                           (str1, "str1"),
                           (str2, "str2"),
                           (str3, "str3"),
                        )
            # @info "Types" x=typeof(x) mode=mode
            @test_reference joinpath(refdir, "Diff", "$(xname)_new.txt") @io2str(render(::IO, mode, x[2])) by=string_check
            @test_reference joinpath(refdir, "Diff", "$(xname)_compare.txt") @io2str(render(::IO, mode, x...)) by=string_check
        end
    end

    @testset "BeforeAfterImage" begin
        mode = BeforeAfterImage()
        for (x, xname) in (
                        #    (img1d_1, "img1d_1"),
                        #    (img1d_2, "img1d_2"),
                        #    (img1d_3, "img1d_3"),
                           (img2d_1, "img2d_1"),
                        #    (img3d_1, "img3d_1")
                        )
            # @info "Types" x=typeof(x) mode=mode
            @test_reference joinpath(refdir, "BeforeAfterImage", "$(xname)_new.txt") @io2str(render(::IO, mode, x[2])) by=string_check
            @test_reference joinpath(refdir, "BeforeAfterImage", "$(xname)_compare.txt") @io2str(render(::IO, mode, x...)) by=string_check
        end
    end

end
