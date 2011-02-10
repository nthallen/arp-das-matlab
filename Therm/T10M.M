% this file assumes therm has two columns, T in C and Rrat which holds
% a ratio value for a class of thermistors. In this case, I multiply by
% 1e7 to get the appropriate value for the 10M thermistors for high temps.
% yielding T, Rt.
% R is defined as the pullup value.
% V is calculated (based on 10V ref)
% C is counts calculated from volts
global Temperature Counts
docalib = 1;
load t10m.dat;
Temperature = t10m(:,1);
Rrat=t10m(:,2);
Rt = Rrat * 1e7;
R = 250e3;
V = 10 * Rt ./ (Rt + R );
Counts = 4096 * (V/10);

% What I'm really interested in now is dT/dCt over the desired temperature
% range.
dT = diff(Temperature); dC = diff(Counts);
T1 = Temperature(1:length(dT)) + dT;
dTdC = dT./dC;
subplot(2,1,1);
plot(Temperature,Counts);
ylabel('Counts');
title(sprintf('10M Thermistor pulled up by %.0fK', R*1e-3));
set(gca, 'Xlim', [0 300]);
subplot(2,1,2);
plot(T1,dTdC);
xlabel('Temperature');
ylabel('dT/dCt');
set(gca, 'Xlim', [0 300]);

if docalib == 1
figure;
CV = allpts( .5 );
TV = interp1(Counts,Temperature,CV);
fid=fopen('calib.tmc', 'w');
fprintf(fid, 'Calibration ( AD12_T10M, CELCIUS ) {' );
for i = [1:length(CV)]
  fprintf(fid, '\n  %4.0f, %6.2f', CV(i)*16, TV(i) );
  if ( i < length(CV) ) fprintf(fid, ','); end
end
fprintf(fid, '\n}\n' );
end
