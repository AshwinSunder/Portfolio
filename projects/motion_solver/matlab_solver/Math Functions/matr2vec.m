
% Function to convert an orientation matrix to an orientation vector
function vec = matr2vec(R)

    [U,~,V]   = svd(R);
    RR = U*V';

    t = trace(RR);
    tr = (t - 1) / 2;
    theta = real(acos(tr));

    r = [RR(3,2) - RR(2,3); ...
         RR(1,3) - RR(3,1); ...
         RR(2,1) - RR(1,2)];

    if sin(theta) > 10^-4
        vth = 1/(2*sin(theta));
        v = r*vth;
        vec = theta*v;

    elseif t-1 > 0
        vec = (.5-(t-3)/12).*r;
    else
        [~, a] = max(diag(R));
        a = a(1);
        b = mod(a,3)+1;
        c = mod(a+1,3)+1;
        
        s = sqrt(R(a,a)-R(b,b)-R(c,c)+1);
        v = zeros(3,1,'like',R);
        v(a) = s/2;
        v(b) = (R(b,a)+R(a,b))/(2*s);
        v(c) = (R(c,a)+R(a,c))/(2*s);
        
        vec = theta*v./norm(v);
    end
end
