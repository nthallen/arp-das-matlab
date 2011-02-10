% h2opaf2.m Generates conversions for WB57 H2O Backup Primary Duct Thermistors
% Based on calibration data from Jasna 7/31/01. I do not know at what point
% this backup ring was actually installed in the instrument.
%
% This program was retroactively corrected 6/6/02 upon realization that
% the pullup resistor is 200K, not 100K

%        1/T = A + B*Ln(R) + C*(Ln(R))^3
% where T is temperature in degrees K, and R is resistance in kOhm.
%             A                B              C
P = [
  2    0.00258532      0.000305839     3.358926E-07
  3    0.00264155      0.000301379     4.107080E-07
  4    0.00258924      0.000309842     3.164956E-07
  5    0.00270707      0.000299345     4.385460E-07
  6    0.00266916      0.000305527     4.343380E-07
  7    0.00267513      0.00030934      2.978320E-07
  8    0.00266856      0.00029842      4.639930E-07
  9    0.00266136      0.000310472     3.943390E-07
];

prefix = 'PAF';
R = 200e3;

n_therms = size(P,1);
Cts = [ 1:4:4093 ]';
Rt = 1e-3*( Cts * R ) ./ ( 4096 - Cts );
LRt = log(Rt);
for i = 1:n_therms
  name = [ prefix num2str(P(i,1)) ];
  Desc=[ name ': 10K Thermistor pulled up by ' num2str(R/1e3) 'K' ];
  fromto = [ 'AD12_' name ', KELVIN' ];
  T = 1 ./ ( P(i,2) + P(i,3).*LRt + P(i,4).*(LRt.^3) );
  gencal2( T, Cts, 1, name, Desc, fromto, 2 );
end

