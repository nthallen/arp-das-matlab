function T = SteinHart( Rtherm, a0, a1, a2 )
% T = SteinHart( Rtherm, a0, a1, a2 )
% T = SteinHart( Rtherm, a )
% Calculates the temperature in Celcius given the
% thermistor resistance and the three coefficients.
% The Steinhart-hart equation is:
%  1/(T+273.15) = a0 + a1*log(Rtherm) + a2*(log(Rtherm)^3)
logR = log(Rtherm);
if nargin == 2
  a1 = a0(2);
  a2 = a0(3);
  a0 = a0(1);
end
T = 1./(a0 + a1 .* logR + a2.*(logR.^3)) - 273.15;
