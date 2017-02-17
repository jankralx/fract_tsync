function [in, out1] = sync_length(in, out1)

if (length(in)>length(out1))
    in=in(1:length(out1));
else
    out1=out1(1:length(in));
end