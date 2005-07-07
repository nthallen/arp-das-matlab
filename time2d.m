function tout = time2d(t)
t1 = t(min(find(~isnan(t))));
day = fix(t1./(24*60*60));
tout = t - day*60*24*60;
