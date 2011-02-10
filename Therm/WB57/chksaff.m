% chksaff.m Generates conversions for WB57 H2O Backup Primary Duct Thermistors
% Calibration values sent from Jasna, 5/6/02

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
R = 100e3;

n_therms = size(P,1);
Cts = [ 3:4:4095 ]';
Rt100 = ( Cts * 100e3 ) ./ ( 4096 - Cts );
Rt200 = ( Cts * 200e3 ) ./ ( 4096 - Cts );
T100 = zeros(size(Cts,1),n_therms);
LRt = log(Rt100);
for i = 1:n_therms
  T100(:,i) = 1 ./ ( P(i,2) + P(i,3).*LRt + P(i,4).*(LRt.^3) );
end
T200 = zeros(size(Cts,1),n_therms);
LRt = log(Rt200);
for i = 1:n_therms
  T200(:,i) = 1 ./ ( P(i,2) + P(i,3).*LRt + P(i,4).*(LRt.^3) );
end

