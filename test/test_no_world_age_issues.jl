using ReferenceTests: render_item, BeforeAfterImage

@testset "world age issues" begin
    function test_render(file)
        # https://github.com/JuliaTesting/ReferenceTests.jl/issues/120
        render_item(BeforeAfterImage(), load(file))
    end
    function test_convert(file)
        ReferenceTests._convert(DataFormat{:TXT}, load(file))
    end
    files = ["references/camera.png"]

    for filename in files
        ref_file = joinpath(@__DIR__, filename)
        if isfile(ref_file)
            @test_reference filename load(ref_file)
            @test_nowarn test_render(ref_file)
            @test_nowarn test_convert(ref_file)
        else
            @info "Skip reference file: $ref_file"
        end
    end
end
