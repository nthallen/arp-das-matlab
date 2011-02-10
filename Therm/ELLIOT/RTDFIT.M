% calculate temperature from fit to SF1B1 data
function T=rtdfit(r)
a=.00112548;
b=2.325826;
c=-243.75348;

T=(c+b*(r)+a*(r).*(r));

