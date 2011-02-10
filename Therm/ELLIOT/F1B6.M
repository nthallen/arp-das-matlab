% calculate temperature from fit to SF1B1 data
function T=f1b1(r)
a=.00288;
b=.00018;
c=6.98e-6;
d=3.87e-6;

T6=1/(a+b*log(r)+c*log(r)*log(r)+d*log(r)*log(r)*log(r));
T=T6;
