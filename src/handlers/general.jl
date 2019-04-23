# Fallback handlers
function test_reference(file::File, actual)
    if actual isa AbstractString
        # we don't use dispatch for this as it is very ambiguous
        # specialization will remove this conditional regardless

        _test_reference(Diff(), file, actual)
    else
        _test_reference(BeforeAfterLimited(), file, actual)
    end
end
