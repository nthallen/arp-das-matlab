function tout = time2d(t,m,s)
% time2d(t)
% t is seconds since 1970 UTC
% tout is seconds since midnight UTC
%
% time2d(h,m,s);
% tout is seconds
if nargin == 1
    t1 = t(min(find(~isnan(t))));
    day = fix(t1./(24*60*60));
    tout = t - day*60*24*60;
else
    tout = t*3600 + m*60 + s;
end