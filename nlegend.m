function H = nlegend( varargin );
% H = nlegend( 'label', ... );
% H = nlegend( [x y w h], 'label', ... );
% Returns a handle to the legend axes
% Checks plot box aspect ratio mode to guess whether
% legend should be formatted for printing or not
% Default position is [ .5 0 0 -1.1 ] which is centered
% slightly above the baseline.
% x and y are in normalized units
% w = 1 => right justifited
% w = 0 => centered
% w = -1 => left justified
% h = 1 => top aligned
% h = 0 => middle aligned
% h = -1 => bottom aligned

na = nargin;
if na == 0
  return
end
if ischar(varargin{1})
  Pos = [ .5 0 0 -1.1 ];
  Txt = varargin;
else
  Pos = varargin{1};
  Txt = { varargin{2:na} };
  na = na-1;
end

printing = 0;
fontsize = 10; % points
axissize = 1.3; % times the fontsize
linelength = 2; % times the fontsize
linespace = .5; % times the fontsize

% create axes. Depending on whether we're printing or not, we
% want the axes to be axissize tall and about .8 times as wide
% as the current axes.
a = gca;
f = gcf;
AU = get(a,'Units');
FPU = get(f,'PaperUnits');

% I use PBARM on the assumption that if I'm formatting
% for printing, I will have set the PlotBoxAspectRatio.
PBARM = get(a,'PlotBoxAspectRatioMode');
printing = strcmp(PBARM,'manual');
if printing
  set(a,'Units','normalized');
  AP = get(a,'Position');
  set(f,'PaperUnits','points');
  PP = get(f,'PaperPosition');
  nfontwd = fontsize/(AP(3)*PP(3));
  nfontht = fontsize/(AP(4)*PP(4));
else
  set(a,'Units','points');
  AP = get(a,'Position');
  nfontwd = fontsize/AP(3);
  nfontht = fontsize/AP(4);
end
set(a,'Units','normalized');
AP = get(a,'Position');
LAP = AP;
LAP(2) = AP(2) + nfontht*axissize; % for debugging...
LAP(4) = AP(4)*nfontht*axissize;
LAP(1) = AP(1) + AP(3)*.1;
LAP(3) = AP(3) * .8;
set(f,'Units','normalized');
H = axes('Position',LAP);
set(H,'Units','normalized');


th = text( zeros(1,na), zeros(1,na), char(Txt{:}) );
set(th,'FontUnits','normalized','FontSize', 1/axissize );
xwd1 = LAP(3)/(nfontwd*AP(3));
set(H,'Xlim',[0 xwd1],'Ylim',[ -axissize/2 axissize/2 ]);
ex = zeros(na,4);
for i=[1:na]
  ex(i,:) = get(th(i),'Extent');
end
txpos = [ 0; cumsum(ex(:,3)) ]';
cellsize = (linelength+3*linespace);
lposa = [0:na]*cellsize + txpos;
lpos = lposa([1:na]);
for i=[1:na]
  set(th(i),'Position',[ lpos(i)+cellsize-linespace, 0 ]);
end
X = [ lpos+linespace; lpos+linespace+linelength ];
Y = zeros(size(X));
hold on;
plot(X,Y);
hold off;
% Experimental truncation of axis dimensions
xwd2 = lposa(na+1)+linespace;
LAP(3) = LAP(3) * xwd2 / xwd1;
LAP(1) = AP(1) + Pos(1)*AP(3) - (LAP(3)*(Pos(3)+1)/2);
LAP(2) = AP(2) + Pos(2)*AP(4) - (LAP(4)*(Pos(4)+1)/2);
set(H, 'PlotBoxAspectRatioMode', 'auto' );
set(H,'Position', LAP, 'Xlim', [ 0 xwd2 ]);

%set(H, 'Visible', 'off', 'tag', 'legend' );
set(H,'tag','legend');
C = get(H, 'Color' );
set(H, 'Xtick', [], 'Ytick', [], 'XColor', C, 'YColor', C );
if printing
  set(H, 'PlotBoxAspectRatio', [ LAP(3)*PP(3) LAP(4)*PP(4) 1 ]);
end

% Restore units to axes, figure
set(a,'Units',AU);
set(f,'PaperUnits',FPU,'CurrentAxes',a);
