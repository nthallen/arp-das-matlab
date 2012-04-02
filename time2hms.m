function [ H, M, S ] = time2hms(T)
% [ H, M, S ] = time2hms(T); % returns H, M, S values
% HMS = time2hms(T); % returns a 3x1 vector containing [ H M S ]
% time2hms(T); % prints time as a string
Hi = floor(T/3600);
MS = T - Hi*3600;
Mi = floor(MS/60);
Si = MS - Mi*60;
if nargout == 3
    H = Hi;
    M = Mi;
    S = Si;
elseif nargout == 1
    H = [ Hi Mi Si ];
else
    Tsec = floor(Si/10);
    Osec = Si - Tsec*10;
    fprintf(1, '%02d:%02d:%d%g\n', Hi, Mi, Tsec, Osec);
end
