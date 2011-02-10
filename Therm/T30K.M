% This file is somewhat obsolete. See README.txt to find where to start
% this file assumes t30k has two columns, T in Rt
% yielding T, Rt.
% R is defined as the pullup value.
% C is counts calculated from Rt and R
% Scale is an integer the counts should be multiplied by before
%  final output.
global Temperature Counts
load t30k.dat;
Temperature = t30k(:,1);
Rt=t30k(:,2);
R = 75e3;
Scale = 1;
Counts = 4096 * Rt ./ (Rt + R );
docalib = 0;

% What I'm really interested in now is dT/dC over the desired temperature
% range.
dT = diff(Temperature); dC = diff(Counts);
T1 = Temperature(1:length(dT)) + dT;
dTdC = dT./dC;
subplot(2,1,1);
plot(Temperature,Counts);
ylabel('Counts');
title(sprintf('30K Thermistor Pulled up by %.0fK', R*1e-3));
subplot(2,1,2);
plot(T1,dTdC);
xlabel('Temperature'); ylabel('dT/dCt');

if docalib == 1
figure;
CV = allpts( .5 );
TV = interp1(Counts,Temperature,CV);
fid=1 %  fopen('calib.tmc', 'w');
fprintf(fid, 'Calibration ( AD12_T30K, CELCIUS ) {' );
for i = [1:length(CV)]
  fprintf(fid, '\n  %4.0f, %6.2f', CV(i)*Scale, TV(i) );
  if ( i < length(CV) ) fprintf(fid, ','); end
end
fprintf(fid, '\n}\n' );
end
