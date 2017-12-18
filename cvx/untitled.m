n=1000; p = rand(n,1);
A = rand(n,n);b = rand(n,1);
eps = 0.0001
cvx_begin
    variable x(n)
    variable y(n)
    variable t1(1)
    variable t2(1)
    minimize( t1 + t2)
    subject to
        norm( x, Inf ) <= t1
        norm( y, Inf) <= t2
        t1 <= 1
        t2 <= 1
        -t1 <= 1
        -t2 <= 1
        x + y == p
%         A*x == b
%         A*y == 0
%         sum_square(x) + sum_square(y) - norm(p,2).^2 <= eps
%        -  sum_square(x) - sum_square(y) + norm(p,2).^2 <= eps
%         p'*x + p'*y == norm(p,2).^2
cvx_end