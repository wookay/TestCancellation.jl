# module TestCancellation

# from julia/test/cancellation.jl
using Test

# Threads.@spawn-style cancellable task (non-sticky, explicitly on the
# default pool - a compute-bound victim must not land on the interactive/io
# thread); returns (task, source).
function cancellable_spawn(f)
    src = CancellationTokenSource()
    t = with(() -> Threads.@spawn(f()), CANCEL_TOKEN => CancellationToken(src))
    return t, src
end

# Start `f` as an @async-style (sticky, co-scheduled) task governed by a
# fresh cancellation source; returns (task, source).
function cancellable(f)
    src = CancellationTokenSource()
    t = with(() -> @async(f()), CANCEL_TOKEN => CancellationToken(src))
    return t, src
end

# wait a little, so cancellation targets are (most likely) started and parked
spin(n=3) = for _ in 1:n; yield(); end

# wait for `t` and assert it failed with the delivered CancellationRequest
function expect_cancelled(t::Task)
    @test_throws TaskFailedException wait(t)
    @test t.result isa CancellationRequest
end

# module TestCancellation
