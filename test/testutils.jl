strip_summary(content::String) = join(split(content, "\n")[2:end], "\n")

function string_check(ref, actual)
    # a over-verbose collection of patterns that we want to ignore during test
    patterns = [
        # Julia v1.6
        "Normed{UInt8,8}" => "N0f8",
        r"Array{(\w+),2}" => s"Matrix{\1}",
        r"Array{(\w+),1}" => s"Vector{\1}",

        # https://github.com/JuliaGraphics/ColorTypes.jl/pull/206
        # r"Gray{\w+}\(([\w\.]+)\)" => s"\1",
        # r"RGB{\w+}\(([\w\.,]+)\)" => s"RGB(\1)",
    ]

    for p in patterns
        actual = replace(actual, p)
        ref = replace(ref, p)
    end

    # Julia v1.4
    ref = join(map(strip, split(ref, "\n")), "\n")
    actual = join(map(strip, split(actual, "\n")), "\n")

    isequal(ref, actual)
end
