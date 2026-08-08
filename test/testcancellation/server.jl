# module test_testcancellation_server

using Test
using Sockets
using Base: CancellationTokenSource, CancellationToken, CancellationRequest, cancel!

# from julia/test/cancellation.jl

# wait a little, so cancellation targets are (most likely) started and parked
spin(n=3) = for _ in 1:n; yield(); end

# wait for `t` and assert it failed with the delivered CancellationRequest
function expect_cancelled(t::Task)
    @test_throws TaskFailedException wait(t)
    @test t.result isa CancellationRequest
end

# live cancellation: Sockets.accept and recv with explicit tokens
host = Sockets.localhost
port, server = Sockets.listenany(host, 0)
src1 = CancellationTokenSource()
t1 = @async Sockets.accept(server; cancel=CancellationToken(src1))
spin()
cancel!(src1)
expect_cancelled(t1)

src2 = CancellationTokenSource()
# the server keeps accepting afterwards
t2 = @async Sockets.accept(server; cancel=CancellationToken(src2))
spin()
sock = Sockets.connect(host, port)
@test fetch(t2) isa Sockets.TCPSocket
close(sock)

cancel!(src2)
wait(t2)
@test t2.result isa Sockets.TCPSocket

close(server)

@test server isa Sockets.TCPServer
@test server.status == Sockets.StatusClosed

# end # module test_testcancellation_server
