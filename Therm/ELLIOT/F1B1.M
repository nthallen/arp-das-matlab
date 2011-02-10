% calculate temperature from fit to SF1B1 data
function T=f1b1(r)
a=.00291;
b=.0002;
c=-1.7367e-6;
d=-1.3083e-6;

T1=1/(a+b*log(r)+c*log(r)*log(r)+d*log(r)*log(r)*log(r));
T=T1;
