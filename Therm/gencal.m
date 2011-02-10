function V = gencal( T, Ct, threshold, Scale, File, Desc, FromTo )
% gencal( T, Ct, threshold, Scale, File, Desc, FromTo )
%   T, Ct
% this file assumes therm has two columns, T in C and Rrat which holds
% a ratio value for a class of thermistors. In this case, I multiply by
% 1e7 to get the appropriate value for the 10M thermistors for high temps.
% yielding T, Rt.
% R is defined as the pullup value.
% V is calculated (based on 10V ref)
% C is counts calculated from volts
global Temperature Counts
Temperature=T;
Counts=Ct;

% What I'm really interested in now is dT/dCt over the desired temperature
% range.
dT = diff(Temperature); dC = diff(Counts);
T1 = Temperature(1:length(dT)) + dT;
dTdC = dT./dC;
figure;
subplot(2,1,1);
plot(Temperature,Counts);
ylabel('Counts');
title(Desc);
set(gca, 'Xlim', [-40 150]);
subplot(2,1,2);
plot(T1,abs(dTdC));
xlabel('Temperature');
ylabel('|dT/dCt|');
set(gca, 'Xlim', [-40 150]);

figure;
CV = allpts( threshold );
TV = interp1(Counts,Temperature,CV);
fid=fopen(File, 'w');
fprintf(fid, ['Calibration ( ' FromTo ' ) {'] );
for i = [1:length(CV)]
  fprintf(fid, '\n  %4.0f, %6.2f', CV(i)*Scale, TV(i) );
  if ( i < length(CV) ) fprintf(fid, ','); end
end
fprintf(fid, '\n}\n' );
fclose(fid);
