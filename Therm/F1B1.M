% calculate temperature from fit to SF1B1 data
function T=f1b1(c)
v = c/6553.6
r = v*250e3./(10-v);
lr = log(r);
a=.00291;
b=.0002;
c=-1.7367e-6;
d=-1.3083e-6;

T1=1/(a+b*lr+c*lr.*lr+d*lr.*lr.*lr);
T=T1;
