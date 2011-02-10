% calculate temperature from fit to SF1B1 data
function T=f1b1(r)
a=.00288;
b=.00021;
c=4.855e-6;
d=3.24e-7;

T5=1/(a+b*log(r)+c*log(r)*log(r)+d*log(r)*log(r)*log(r));
T=T5;
