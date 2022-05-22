@testset "world age issues" begin
    files = ["references/camera.png"]

    for filename in files
        ref_file = joinpath(@__DIR__, filename)
        if isfile(ref_file)
            @test_reference filename load(ref_file)
        else
            @info "Skip reference file: $ref_file"
        end
    end
end
