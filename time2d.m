%time2d.m
function[t]=time2d(t)
t1=t(1);
day=fix(t1./(24*60*60));
t=t-day*60*24*60;
%hour=fix(time./(60*60));
%min=fix((time-hour*60*60)./60);
%sec=time-hour*60*60-min*60
