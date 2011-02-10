function gast( Therm_No );
% gast( Therm_No );
% Cavity Ringdown Gas#T Calibrations
% As of 4/26/02 these are nominally 10K thermistors pulled up by
% 75K. This will probably change in the near future.
% This routine applies a correction based on a resistance
% measurement at 21.3 degrees.
load TM4.mat; % contains T, Rrat
R21_3 = [ 12.75 10.28 10.88 12.65 ] * 1e3;
Rrat21_3 = interp1( T, Rrat, 21.3 );
R25 = R21_3/Rrat21_3;
Rpullup = 75e3;
Rt = Rrat * R25(Therm_No);
Cts = 4096 * Rt ./ (Rt + Rpullup );
Name = [ 'Gas' num2str(Therm_No) 'T' ];
Desc=[ Name ': ' num2str(R25(Therm_No)/1000) ...
    'K Thermistor pulled up by ' num2str(Rpullup/1000) 'K' ];
gencal2( T, Cts, 1, Name, Desc, [ 'AD12_' Name ', CELCIUS' ], 2 );
