function [x1,x2] = decompose(b)
n = length(b);
cvx_begin
    variable x1(n)
    variable x2(n)
    variable t1(1)
    variable t2(1)
    minimize(t1 + t2)
    subject to
        norm( x1, Inf ) <= t1
        norm( x2, Inf) <= t2
        t1 <= 1
        t2 <= 1
        -t1 <= 0
        -t2 <= 0
        x1 + x2 == b
%         sum_square(x) + sum_square(y) - norm(p,2).^2 <= eps
%        -  sum_square(x) - sum_square(y) + norm(p,2).^2 <= eps
%         p'*x + p'*y == norm(p,2).^2
cvx_end