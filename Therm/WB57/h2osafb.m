% h2osaff.m Generates conversions for WB57 H2O Backup Primary Duct Thermistors
% Calibration values sent from Jasna, 5/6/02 This should apply to all 2002 flights.
%
% Retroactively corrected 6/6/02 upon realization that pullup is 200K, not 100K

%        1/T = A + B*Ln(R) + C*(Ln(R))^3
% where T is temperature in degrees K, and R is resistance in Ohm.
%             A                B              C
P = [
  1   0.000913541   0.000248205     1.758500E-07 
  2   0.00083603    0.000258824     1.447E-07
  3   0.000867462   0.000258605     1.523E-07
  4   0.000893263   0.000256723     1.547E-07
  5   0.000913317   0.000252979     1.677E-07
  6   0.000894588   0.000257194     1.527E-07
  7   0.000899754   0.000256214     1.583E-07
];

prefix = 'SAFB';
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

