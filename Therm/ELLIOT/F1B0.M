% calculate temperature from fit to SF1B1 data
function T=f1b1(r)
a=.00286;
b=.00021;
c=-1.7654e-6;
d=-2.8688e-7;

T0=1/(a+b*log(r)+c*log(r)*log(r)+d*log(r)*log(r)*log(r));
T=T0;
