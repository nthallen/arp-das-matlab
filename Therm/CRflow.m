function CRflow()
% CRflow()
% Generate calibration curves for CRflow instrument

% RD columns taken from CRflow.txt
% column 1: Thermistor serial number
% column 2: a0 steinhart-hart coefficient
% column 3: a1 steinhart-hart coefficient
% column 4: a2 steinhart-hart coefficient
% column 5: Pull Up value in MOhms
% column 6: Cell#T channel number

RD = [
  115.000  0.000392114  0.000204514 7.57084e-008	1.0002	0
  120.000  0.000349979  0.000208646 6.29344e-008	1.0004	7
  121.000  0.000337901  0.000210837 6.19850e-008	1.0003	8
  122.000  0.000338711  0.000210194 6.20473e-008	1.0011	3
  123.000  0.000342935  0.000208927 6.22916e-008	1.0008	4
  124.000  0.000363223  0.000207926 6.36308e-008	1.0006	6
  125.000  0.000347008  0.000209566 6.14020e-008	1.0003	5
  127.000  0.000349868  0.000210364 6.25388e-008	1.0006	1
  129.000  0.000330710  0.000210110 6.02388e-008	1.0000	9
  130.000  0.000335786  0.000210653 5.77111e-008	1.0007	2
];

SN = RD(:,1)';
a0 = RD(:,2)';
a1 = RD(:,3)';
a2 = RD(:,4)';
RP = RD(:,5)'*1e6; % Pullup
Tnum = RD(:,6);

% I will make the basic assumption that the thermistors are
% pulled up to the reference voltage of the A/D.
% The Steinhart-hart equation is:
%  1/T = a0 + a1*log(R) + a2*(log(R)^3)
Cts = [1:4095]';
col = ones(size(Cts));
row = ones(1,size(RD,1));
CtsM = Cts*row;
Rtherm = CtsM .* (col*RP) ./ (4096-CtsM);
logR = log(Rtherm);
T = 1./(col*a0 + (col*a1) .* logR + (col*a2).*(logR.^3)) - 273.15;
fid = fopen( 'CRflow.tmc', 'w' );
for i=1:length(Tnum)
  typenm = sprintf( 'Cell%dT_t', Tnum(i) );
  FromTo = sprintf( '%s, CELCIUS', typenm );
  Desc = sprintf( '%s 1M Thermistor (SN %d) Pulled up by %.4fM', ...
    typenm, SN(i), RP(i)*1e-6 );
  gencal2( T(:,i), Cts, 1, typenm, Desc, FromTo, 2, fid );
end
fclose(fid);
