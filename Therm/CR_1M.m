function CR_1M()
% CR_1M()
% Generate calibration curves for CR 1M Thermistor Channels

% RD columns taken from CRflow.txt
% column 1: Thermistor serial number
% column 2: R(T=0) MOhm
% column 3: R(T=25) MOhm
% column 4: R(T=37) MOhm
% column 5: R(T=50) MOhm
% column 6: a0 steinhart-hart coefficient (x1e-4)
% column 7: a1 steinhart-hart coefficient (x1e-4)
% column 8: a2 steinhart-hart coefficient (x1e-8)
% column 9: Pull Up value in MOhms
% Data system calibration with calibrated resistances:
% column 10: Open
% column 11: R=10.021 KOhm
% column 12: R=1.0128 KOhm

%  [ 133 3.29e6 0.96e6 0.56e6 0.33e6 2.83e-4 2.12e-4 5.9e-8  1.0002e6 ], 'Gas1T'
%  [ 132 2.78e6 0.8e6  0.47e6 0.27e6 3.46e-4 2.1e-4  6.09e-8 1.0005e6 ], 'Gas2T'
%  [ 103 2.83e6 0.82e6 0.48e6 0.28e6 3.63e-4 2.08e-4 6.36e-8 1.0004e6 ], 'CG1MT'
%  [ 106 2.67e6 0.77e6 0.45e6 0.26e6 3.52e-4 2.10e-4 6.24e-8 1.0004e6 ], 'SH1MT'

RD = {
  [ 103 2.772000 0.804200 0.449600 0.269300 3.889070 2.0690500 6.1889400 1.0004 4096 40.62 4.1426 ], 'CG1MT'
  [ 106 2.793000 0.803400 0.469300 0.273100 3.527730 2.0956000 6.0461200 1.0004 4096 40.62 4.1426 ], 'SH1MT'
  [ 132 2.781000 0.802300 0.469900 0.273600 3.456390 2.1002300 6.0908300 1.0005 4092.8 38.9 2.2 ], 'Gas2T'
  [ 133 3.289000 0.956500 0.561900 0.328600 2.826420 2.1184300 5.9005600 1.0002 4091.5 28.3 2.2 ], 'Gas1T'
};
ResCal = [ 10.021e3 1.0128e3 ]; % Calibration resistors
Tcal = [ 0 25 37 50 ];
% I will make the basic assumption that the thermistors are
% pulled up to the reference voltage of the A/D.
% The Steinhart-hart equation is:
%  1/T = a0 + a1*log(R) + a2*(log(R)^3)
fid = fopen( 'CR_1M.tmc', 'w' );
for i=1:length(RD)
  SN = RD{i,1}(1);
  Rcal = RD{i,1}(2:5)*1e6;
  a0 = RD{i,1}(2+4)*1e-4;
  a1 = RD{i,1}(3+4)*1e-4;
  a2 = RD{i,1}(4+4)*1e-8;
  RP = RD{i,1}(5+4)*1e6;
  Ncal = RD{i,1}(10:12);
  
  % First Calibrate the data system
  RatCal = [ 1 ResCal./(ResCal+RP) ];
  V = polyfit(RatCal,Ncal,1);
  fprintf(1,'Data System Cal for %s: N = %.1f * Rat + %.2f\n', RD{i,2}, V(1), V(2) );

  % Now double-check our Steinhart/Hart parameters
  Tcheck = SteinHart(Rcal, a0, a1, a2 );
  figure; plot(Tcal, Tcheck-Tcal, '*');
  ylabel('Error Celcius');
  xlabel('Celcius');
  title(sprintf('%s SN %d', RD{i,2}, SN ));

  Cts = [1:4095]';
  % Rtherm = Cts .* RP ./ (4096-Cts);
  Rtherm = RP*(Cts-V(2))./(V(1)+V(2)-Cts);
  rok = Rtherm > 0;
  Cts = Cts(rok);
  Rtherm = Rtherm(rok);
  
  T = SteinHart(Rtherm, a0, a1, a2);
  % logR = log(Rtherm);
  % T = 1./(col*a0 + (col*a1) .* logR + (col*a2).*(logR.^3)) - 273.15;
  typenm = sprintf( 'AD12_%s', RD{i,2} );
  FromTo = sprintf( '%s, CELCIUS', typenm );
  Desc = sprintf( '%s 1M Thermistor (SN %d) Pulled up by %.4fM', ...
    typenm, SN, RP*1e-6 );
  gencal2( T, Cts, 1, typenm, Desc, FromTo, 2, fid );
end
fclose(fid);

function T = SteinHart( Rtherm, a0, a1, a2 )
  logR = log(Rtherm);
  T = 1./(a0 + a1 .* logR + a2.*(logR.^3)) - 273.15;
