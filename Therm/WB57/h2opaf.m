% h2opaf.m Generates conversions for WB57 H2O Primary Duct Thermistors
% Reads prim_therms.mat. This conversion applies to VERSION 1.1 data
% throughout the Aug01 Costa Rica Mission, although there may have
% been a replacement of thermistors at some point TBD. Based on
% calibration data supplied by Elliot 9 Apr 2001
%
% Retroactively corrected 6/6/02 upon realization that pullup is
% actually 200K, not 100K

load prim_therms.mat
prefix = 'PAF';
Tnums = [2 3 5 6 8 9];
R = 200e3;

n_therms = size(therm,2)-1;
if n_therms ~= length(Tnums)
  error('Number of therms is incorrect');
end
[T,I] = sort(therm(:,n_therms+1));
Rt = therm(I,[1:n_therms])*1e3;
Cts = 4096 * Rt ./ (Rt + R );
for i = 1:length(Tnums)
% for i=1:1
  name = [ prefix num2str(Tnums(i)) ];
  Desc=[ name ': 10K Thermistor pulled up by ' num2str(R/1e3) 'K' ];
  fromto = [ 'AD12_' name ', KELVIN' ];
  gencal2( T, Cts(:,i), 1, name, Desc, fromto, 2 );
end

