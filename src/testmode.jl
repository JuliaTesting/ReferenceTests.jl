#################################################
# Test mode
# This controls how test cases are handled
abstract type TestMode end
struct InteractiveMode <: TestMode end
struct NonInteractiveMode <: TestMode end

"""
Predefined CI environment variables

# References

* Travis: https://docs.travis-ci.com/user/environment-variables/#default-environment-variables
* Appveyor: https://www.appveyor.com/docs/environment-variables/
"""
const CI_ENVIRONMENTS = Dict(
    "CI" => "true",
    "APPVEYOR" => "true",
    "TRAVIS" => "true",
    "CONTINUOUS_INTEGRATION" => "true",
    "DEBIAN_FRONTEND" => "noninteractive"
)

function TESTMODE()
    global GLOBAL_TESTMODE
    if !isdefined(ReferenceTests, :GLOBAL_TESTMODE)
        # it's only called once in runtime
        GLOBAL_TESTMODE = _get_testmode()
    end
    return GLOBAL_TESTMODE
end

function _get_testmode()
    # test if this package is used in a CI environment
    common_keys = collect(intersect(keys(ENV), keys(CI_ENVIRONMENTS)))
    matched_envs = map(common_keys) do k
        # some variables might have different cases in different CI platforms
        # e.g., in Appveyor, ENV["CI] is "True" in Windows and "true" in Ubuntu.
        lowercase(ENV[k])==lowercase(CI_ENVIRONMENTS[k])
    end
    has_testenv = any(matched_envs)
    has_testenv && return NonInteractiveMode()

    # fallback
    @info "You need to run the tests interactively with 'include(\"test/runtests.jl\")' to update references."
    return isinteractive() ? InteractiveMode() : NonInteractiveMode()
end
