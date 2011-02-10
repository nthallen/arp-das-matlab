% calculate temperature from fit to SF1B1 data
function T=f1b1(r)
a=.00287;
b=.00019;
c=5.94e-6;
d=1.024e-6;

T4=1/(a+b*log(r)+c*log(r)*log(r)+d*log(r)*log(r)*log(r));
T=T4;
