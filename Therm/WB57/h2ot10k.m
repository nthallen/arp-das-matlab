% h2o10K generates a simplified general-use calibration for all 10K thermistors
% Calibration values sent from Jasna, 5/6/02 This should apply to all 2002 flights.

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
 12   0.000805359   0.000262193     1.390000E-07
 13   0.000802361   0.000263891     1.3381E-07
 15   0.000837134   0.00025843      1.486E-07
 16   0.000793969   0.000265945     1.337E-07
];


prefix = 'T10K';
R = 200e3;

n_therms = size(P,1);
Cts = [ 3:4:4095 ]';
Rt = ( Cts * R ) ./ ( 4096 - Cts );
LRt = log(Rt);
T = zeros(size(Cts,1),n_therms);
for i = 1:n_therms
  T(:,i) = 1 ./ ( P(i,2) + P(i,3).*LRt + P(i,4).*(LRt.^3) );
end
Tavg = mean(T')';
name = 'T10K';
Desc=[ name ': 10K Thermistor pulled up by ' num2str(R/1e3) 'K' ];
fromto = [ 'AD12_' name ', KELVIN' ];
gencal2( Tavg, Cts, 1, name, Desc, fromto, 2 );
