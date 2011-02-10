function twtaf( compare );
% twtaf( [ compare ] );
% Generate calibrations for TW TAFF thermistors. If compare > 0, display
% a plot instead comparing the new and old calibrations.
%
% New calibrations of Total Water TAFF thermistors performed by David Sayres
% June 2002 and presumably pertaining to May/June test flights on the WB57
% as well as CRYSTAL/FACE science flights.
%
% Original calibration was performed by Elliot prior to Costa Rica flights
% of August, 2001. That calibration referred to the thermistors based on
% an arbitrary numbering which was later tied to specific pins. As such
% TAFF1 was dubbed thermistor '4', TAFF2 was '2' and TAFF3 was '3'.
% That is to say thermistor '1' was not working and the ring was patched
% to feed thermistor '4' into 1's position.
%
% The upshot is that TAFF1 is assigned a type AD12_TAF4. It is also
% relevant to consider this when comparing new and old calibrations.
% The current calibrations are in the expected order, but note that
% what is now known as TAFF1 was thermistor '4' in the previous
% calibration.
%
% R5 and R6 are reference thermistors. The parameters of their calibration
% curves are defined in RefParams.

if nargin < 1
  compare = 0;
end

% T    5      6    1-2   3-4   5-6  11-12 : Pin numbers
% T   R5     R6   TAFF1 TAFF2 TAFF3 TAFF6 : TM Mnemonics
% T    -      -     4     2     3     6   : Old Resistor Number
taf = [
-10 377.4 381.7 42.7  43.8  44.4  50.3
  0 248.4 250.4 26.6  26.9  27.6  30.8
 10 173.1 174.2 17.73 17.7  18.23 20.12
 20 127.6 128.5 12.37 12.32 12.7  14.06
 30  88.5  87.5  8.00  7.91  8.20  9.05
];
% The following was excluded because the 17.12 reading is suspect
% 10 170.3 172.3 17.5  17.53 17.12 20.07
T = taf(:,1)+273.15;
R5 = taf(:,2);
R6 = taf(:,3);
R = taf(:,[4:6])*1e3;
Tnums = [ 4 2 3 ];

%     A               B               C
% Thermistor 5 and 6
RefParams = [
  0.001761802     0.000342881     1.335661E-07
  0.001766278     0.000342128     1.38167E-07
];

% A + B*ln(R) + C*(ln(R))^3 - 1/T = 0     (R in Ohms, T in Kelvin)

T5 = 1./(RefParams(1,1) + RefParams(1,2)*log(R5) + RefParams(1,3)*(log(R5).^3) );
T6 = 1./(RefParams(2,1) + RefParams(2,2)*log(R6) + RefParams(2,3)*(log(R6).^3) );

T56 = mean([ T5'; T6' ])';

ABC = zeros(3,size(R,2));
for i = 1:size(R,2)
  M = [ ones(size(R,1),1) log(R(:,i)) log(R(:,i)).^3 ];
  ABC(:,i) = M\(1./T56);
end

if compare
  Rfit = [ 8:1:45]'*1e3;
  M = [ ones(size(Rfit)) log(Rfit) log(Rfit).^3 ];
  Tfit = 1./(M*ABC);

  old = load('twv_therms.mat');

figure;
[ Told, I ] = sort(old.therm(:,6));
Rold = old.therm(I,[3 1 2])*1e3;
h1 = plot( Told, Rold, ':+');
hold on;
h2 = plot( T56, R, '*' );
h3 = plot( Tfit, Rfit, '-' );
hold off;
xlim([260 305]);
legend([h1;h3], 'T1 old', 'T2 old', 'T3 old', 'T1 new', 'T2 new', 'T3 new' );
xlabel('Kelvin');
ylabel('Ohms');
title('Total Water Primary Thermistor Calibrations');
else
  R = 10e3;
  Cts = [1:4095]'; % 4096 * Rt ./ (Rt + R );
  Rfit = Cts*R./(4096-Cts);
  M = [ ones(size(Rfit)) log(Rfit) log(Rfit).^3 ];
  Tfit = 1./(M*ABC) - 273.15;
  prefix = 'TAF';
  for i = 1:size(Tfit,2)
    name = [ prefix num2str(Tnums(i)) ];
    Desc=[ name ': 10K Thermistor pulled up by ' num2str(R/1e3) 'K' ];
    fromto = [ 'AD12_' name ', CELCIUS' ];
    gencal2( Tfit(:,i), Cts, 1, name, Desc, fromto, 2 );
  end
end
