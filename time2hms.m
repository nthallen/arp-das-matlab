function [ H, M, S ] = time2hms(T)
% [ H, M, S ] = time2hms(T);
% HMS = time2hms(T);
H = floor(T/3600);
MS = T - H*3600;
Mi = floor(MS/60);
Si = MS - Mi*60;
if nargout == 3
    M = Mi;
    S = Si;
else
    H = [ H Mi Si ];
end
