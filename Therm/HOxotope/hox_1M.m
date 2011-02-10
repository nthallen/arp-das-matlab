function HOx_1M()
% HOx_1M()
% Generate calibration curves for HOx 1M Thermistor Channels

% RD columns taken from Liz's spreadsheet
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

RD = {
 [114 2.709000 0.782300 0.458100 0.266900 3.510200 2.0998600 6.1419700 1.0000 4078 2040 43 7], 'DucT1'
 [116 2.684000 0.773900 0.453100 0.263900 3.468880 2.1080400 5.9678300 1.0000 4095 2050 43 7], 'DucT2'
};
ResCal = [ 1.0002e6 10.021e3 1.0128e3 ]; % Calibration resistors
Tcal = [ 0 25 37 50 ];
% I will make the basic assumption that the thermistors are
% pulled up to the reference voltage of the A/D.
% The Steinhart-hart equation is:
%  1/T = a0 + a1*log(R) + a2*(log(R)^3)
fid = fopen( 'HOX_1M.tmc', 'w' );
for i=1:length(RD)
  SN = RD{i,1}(1);
  Rcal = RD{i,1}(2:5)*1e6;
  a0 = RD{i,1}(2+4)*1e-4;
  a1 = RD{i,1}(3+4)*1e-4;
  a2 = RD{i,1}(4+4)*1e-8;
  RP = RD{i,1}(5+4)*1e6;
  Ncal = RD{i,1}(10:13);
  
  % First Calibrate the data system
  RatCal = [ 1 ResCal./(ResCal+RP) ];
  V = polyfit(RatCal,Ncal,1);
  Nfit = polyval(V,RatCal);
  figure; plot(Nfit-Ncal,'*');
  ylabel('Bits');
  ttl = sprintf('Data System Cal for %s: N = %.1f * Rat + %.2f', RD{i,2}, V(1), V(2) );
  title(ttl);
  fprintf(1,'%s\n', ttl);
  

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
  gencal2( T, Cts, 16, typenm, Desc, FromTo, 2, fid );
end
fclose(fid);
