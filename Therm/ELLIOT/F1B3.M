% calculate temperature from fit to SF1B1 data
function T=f1b1(r)
a=.00282;
b=.00016;
c=-.00003;
d=.0000;

T3=1/(a+b*log(r)+c*log(r)*log(r)+d*log(r)*log(r)*log(r));
T=T3;
