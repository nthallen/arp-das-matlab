function a = nsubpos( nYbins, nXbins, Ybin, Xbin );
% a = nsubpos( nYbins, nXbins, Ybin, Xbin );
% Returns position for subplot axes.
% Like subplot(), but doesn't leave any space between
% the figures. It is left up to the user to shut of
% Xticklabel's for all but the bottom plot and do other
% cleanup things, like clear the topmost ylabel.
LM = .1;
RM = .1;
TM = .1;
BM = .1;
AW = (1 - (LM + RM))/nXbins;
AH = (1 - (TM + BM))/nYbins;
if length(Ybin) > 1
  NY = Ybin(2);
else
  NY = 1;
end
if length(Xbin) > 1
  NX = Xbin(2);
else
  NX = 1;
end
a = [ LM+(Xbin(1)-1)*AW  BM+(nYbins-Ybin(1))*AH AW*NX AH*NY ];
