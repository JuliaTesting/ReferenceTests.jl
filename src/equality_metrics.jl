# ---------------------------------
# Image

default_image_equality(reference, actual) = psnr_equality()(reference, actual)

"""
    psnr_equality(threshold=25) -> f

Generates an equality comparison function in terms of Peak Signal-to-Noise Ratio (PSNR).

The return function `f` accepts two images `reference` and `actual` as its inputs;
`f(reference, actual) == true` if `psnr(reference, actual) >= threshold`.

This function is useful for image comparison, for example:

```julia
@test_reference "references/camera.png" testimage("cameraman") by=psnr_equality(20)
```
"""
function psnr_equality(threshold=25)
    function (ref, x)
        rst = _psnr(ref, x)
        if rst >= threshold
            return true
        else
            @warn("test fails because PSNR $rst < $threshold")
            return false
        end
    end
end

# a simplified PSNR is sufficient since we only use it to approximately compare two images
_psnr(ref::AbstractArray{<:Color3}, x::AbstractArray{<:Color3}) =
    _psnr(channelview(RGB.(ref)), channelview(RGB.(x)), 1.0)

_psnr(ref::AbstractArray{<:AbstractGray}, x::AbstractArray{<:AbstractGray}) =
    _psnr(channelview(ref), channelview(x), 1.0)

_psnr(ref::AbstractArray{<:Real}, x::AbstractArray{<:Real}, peakval::Real) =
    20log10(peakval) - 10log10(euclidean(ref, x))
