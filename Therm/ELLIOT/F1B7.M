% calculate temperature from fit to SF1B1 data
function T=f1b1(r)
a=.00288;
b=.00018;
c=.00001;
d=1.1276e-6;

T7=1/(a+b*log(r)+c*log(r)*log(r)+d*log(r)*log(r)*log(r));
T=T7;
