% calculate temperature from fit to SF1B1 data
function T=f1b1(r)
a=.0028;
b=.00012;
c=.00002;
d=.00002;

T2=1/(a+b*log(r)+c*log(r)*log(r)+d*log(r)*log(r)*log(r));
T=T2;
