function [ H, M, S ] = time2hms(T)
% [ H, M, S ] = time2hms(T); % returns H, M, S values
% HMS = time2hms(T); % returns a 3x1 vector containing [ H M S ]
% time2hms(T); % prints time as a string
S = sign(T);
T = T.*S;
Hi = floor(T/3600);
MS = T - Hi*3600;
Mi = floor(MS/60);
Si = MS - Mi*60;
if nargout == 3
    H = Hi.*S;
    M = Mi.*S;
    S = Si.*S;
elseif nargout == 1
    H = [ Hi.*S Mi.*S Si.*S ];
else
    Tsec = floor(Si/10);
    Osec = Si - Tsec*10;
    Stxt = {'-', ' ', ' '};
    fprintf(1, '%s%02d:%02d:%d%g\n', Stxt{S+2}, Hi, Mi, Tsec, Osec);
end
