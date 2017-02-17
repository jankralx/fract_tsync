function [out]=vector_shift(in,q)

if (q>0)
    out=in(q+1:end);  
end

if (q<0)
    q = -q;
    if (size(in,1)>1)
        out = [zeros(q,1); in];
    else
        out = [zeros(1,q) in];
    end
end

if (q==0)
    out=in;
end

end 

