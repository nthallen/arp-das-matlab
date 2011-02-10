% this file assumes t30k has two columns, T in Rt
% yielding T, Rt.
% R is defined as the pullup value.
% V is calculated (based on 10V ref)
% C is counts calculated from volts
global Temperature Counts
load t30k.dat;
Temperature = t30k(:,1);
Rt=t30k(:,2);
R = 30e3;
V = 8 * R ./ (Rt + R );
Counts = 256 * (V/10);
docalib = 1;

% What I'm really interested in now is dT/dC over the desired temperature
% range.
dT = diff(Temperature); dC = diff(Counts);
T1 = Temperature(1:length(dT)) + dT;
dTdC = dT./dC;
subplot(2,1,1);
plot(Temperature,Counts);
ylabel('Counts');
title(sprintf('30K Thermistor Pulled down by %.0fK', R*1e-3));
subplot(2,1,2);
plot(T1,dTdC);
xlabel('Temperature'); ylabel('dT/dCt');

if docalib == 1
figure;
CV = allpts( .5 );
TV = interp1(Counts,Temperature,CV);
fid=1 %  fopen('calib.tmc', 'w');
fprintf(fid, 'Calibration ( AD12_AUXT, CELCIUS ) {' );
for i = [1:length(CV)]
  fprintf(fid, '\n  %4.0f, %6.2f', CV(i), TV(i) );
  if ( i < length(CV) ) fprintf(fid, ','); end
end
fprintf(fid, '\n}\n' );
end
