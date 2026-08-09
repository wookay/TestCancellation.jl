module test_testcancellation_server

using Test
using Sockets
using TestCancellation

# from julia/test/cancellation.jl

# @testset "explicit cancel keyword arguments" begin
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

end # module test_testcancellation_server
