function HOX_1M()
% HOX_1M()
% Generate calibration curves for HOX's 1M Thermistor Channels

% RD columns taken from CRflow.txt
% column 1: Thermistor serial number
% column 2: a0 steinhart-hart coefficient
% column 3: a1 steinhart-hart coefficient
% column 4: a2 steinhart-hart coefficient
% column 5: Pull Up value in MOhms
% column 6: Cell#T channel number

RD = {
  [ 114 2.91e-4 2.14e-4 5.04e-8 1e6 ], 'DucT1'
  [ 116 3.72e-4 2.07e-4 6.29e-8 1e6 ], 'DucT2'
};

Cts = [1:4095]';
col = ones(size(Cts));
% I will make the basic assumption that the thermistors are
% pulled up to the reference voltage of the A/D.
% The Steinhart-hart equation is:
%  1/T = a0 + a1*log(R) + a2*(log(R)^3)
fid = fopen( 'HOX_1M.tmc', 'w' );
for i=1:length(RD)
  RP = RD{i,1}(5);
  a0 = RD{i,1}(2);
  a1 = RD{i,1}(3);
  a2 = RD{i,1}(4);
  SN = RD{i,1}(1);
  Rtherm = Cts .* RP ./ (4096-Cts);
  logR = log(Rtherm);
  T = 1./(col*a0 + (col*a1) .* logR + (col*a2).*(logR.^3)) - 273.15;
  typenm = sprintf( 'AD12_%s', RD{i,2} );
  FromTo = sprintf( '%s, CELCIUS', typenm );
  Desc = sprintf( '%s 1M Thermistor (SN %d) Pulled up by %.4fM', ...
    typenm, SN, RP*1e-6 );
  gencal2( T, Cts, 16, typenm, Desc, FromTo, 2, fid );
end
fclose(fid);
