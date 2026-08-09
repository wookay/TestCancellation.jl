module TestCancellation

export      CancellationTokenSource, CancellationToken, CancellationRequest, cancel!
using Base: CancellationTokenSource, CancellationToken, CancellationRequest, cancel!

export      CANCEL_TOKEN, CANCEL_REQUEST_ABANDON_EXTERNAL, CANCEL_REQUEST_SAFE
using Base: CANCEL_TOKEN, CANCEL_REQUEST_ABANDON_EXTERNAL, CANCEL_REQUEST_SAFE

export                   with
using Base.ScopedValues: with

export cancellable_spawn, cancellable, spin, expect_cancelled
# from julia/test/cancellation.jl
include("cancellation.jl")

end # module TestCancellation
