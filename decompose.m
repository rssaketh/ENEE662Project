function [x1,x2] = decompose(A, b1, b2, b)
n = length(b1);
disp('Starting Optimization.......')
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
        -x1 <= 0
        -x2 <= 0
%         A*x1 - b1 == 0
%         A*x2 - b2 == 0
        x1 + x2 == b
%         sum_square(x) + sum_square(y) - norm(p,2).^2 <= eps
%        -  sum_square(x) - sum_square(y) + norm(p,2).^2 <= eps
%         p'*x + p'*y == norm(p,2).^2
cvx_end
disp('Optimization finished....')