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

% The non-printing versions don't behave well when the image is
% resized. This can be fixed with a resize function (which belongs
% to the figure) In order for the resize function to work, we
% need to store some information with the legend, specifically
% which axes the legend is attached to and what the position
% definition is.

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
  nfontwd = fontsize/AP(3); % char width as fraction of axis width
  nfontht = fontsize/AP(4); % char height as a fraction of the axis height
end
set(a,'Units','normalized');
AP = get(a,'Position');
LAP = AP;
LAP(2) = AP(2) + nfontht*axissize;
LAP(4) = AP(4)*nfontht*axissize;
LAP(1) = AP(1) + AP(3)*.1;
LAP(3) = AP(3) * .8;
set(f,'Units','normalized');
H = axes('Position',LAP); % in normalized units
set(H,'Units','normalized');


% display all the legends on top of each other
th = text( zeros(1,na), zeros(1,na), char(Txt{:}) );
set(th,'FontUnits','normalized','FontSize', 1/axissize );
xwd1 = LAP(3)/(nfontwd*AP(3)); % current legend width in characters
set(H,'Xlim',[0 xwd1],'Ylim',[ -axissize/2 axissize/2 ]);
ex = zeros(na,4);
for i=[1:na]
  ex(i,:) = get(th(i),'Extent'); % Data units which should be characters
end
txpos = [ 0; cumsum(ex(:,3)) ]'; % what units?
cellsize = (linelength+3*linespace); % characters
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
xwd2 = lposa(na+1);
LAP(3) = LAP(3) * xwd2 / xwd1;
LAP(1) = AP(1) + Pos(1)*AP(3) - (LAP(3)*(Pos(3)+1)/2);
LAP(2) = AP(2) + Pos(2)*AP(4) - (LAP(4)*(Pos(4)+1)/2);
set(H, 'PlotBoxAspectRatioMode', 'auto' );
set(H,'Position', LAP, 'Xlim', [ 0 xwd2 ]);

%set(H, 'Visible', 'off', 'tag', 'legend' );
set(H,'tag','nlegend');
C = get(H, 'Color' );
set(H, 'Xtick', [], 'Ytick', [], 'XColor', C, 'YColor', C );

% Restore units to axes, figure
set(a,'Units',AU);

if printing
  FU = get(f,'Units');
  set(f,'Units','Points');
  set(H, 'PlotBoxAspectRatio', [ LAP(3)*PP(3) LAP(4)*PP(4) 1 ]);
  set(f,'Units',FU);
else
  set(H, 'Units', 'Points', 'UserData', struct('parent', a, 'Pos', Pos ));
  set(f, 'ResizeFcn', 'nlegend_rs' );
end
set(f,'PaperUnits',FPU,'CurrentAxes',a);
