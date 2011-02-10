% h2osaff.m Generates conversions for WB57 H2O Primary Duct Thermistors
% Calibration values sent from Jasna, 5/6/02. This applies to flights in May, 2002.
% During that series, all of these thermistors failed due to trauma, so new
% calibrations will be in order (with a different type of thermistor).
%
% This program was retroactively corrected 6/6/02 upon realization that
% the pullup resistor is 200K, not 100K

%        1/T = A + B*Ln(R) + C*(Ln(R))^3
% where T is temperature in degrees K, and R is resistance in Ohm.
%             A                B              C
P = [
      2 0.000805359     0.000262193     1.390000E-07
      3 0.000802361     0.000263891     1.3381E-07
      5 0.000837134     0.00025843      1.486E-07
      6 0.000793969     0.000265945     1.337E-07
];

% Note conversions are labeled 'PAF' based on pin number, but the
% actual data are identified as SAFF for historical reasons. The
% ring is actually located in the primary duct, but we're plugging
% into a water DP that doesn't know about primary ducts.

prefix = 'PAF';
R = 200e3;

n_therms = size(P,1);
Cts = [ 3:4:4095 ]';
Rt = ( Cts * R ) ./ ( 4096 - Cts );
LRt = log(Rt);
for i = 1:n_therms
  name = [ prefix num2str(P(i,1)) ];
  Desc=[ name ': 10K Thermistor pulled up by ' num2str(R/1e3) 'K' ];
  fromto = [ 'AD12_' name ', KELVIN' ];
  T = 1 ./ ( P(i,2) + P(i,3).*LRt + P(i,4).*(LRt.^3) );
  gencal2( T, Cts, 1, name, Desc, fromto, 2 );
end

