function nlegend_rs
% Resize function for nlegends. Probably needs to be set on the figure.
f = gcbo;
Hs = findobj(f, 'type','axes','tag','nlegend');
FPU = get(f,'PaperUnits');
set(f,'Units','normalized');
for H = Hs'
  UD = get(H,'UserData');
  a = UD.parent;
  Pos = UD.Pos;
  AU = get(a,'Units');
  set(a,'Units','normalized');
  AP = get(a,'Position');
  set(a,'Units',AU);
  
  if AP(3) > 0 && AP(4) > 0
    set(H,'Units','normalized');
    LAP = get(H,'Position');
    LAPwas = LAP;
    if all(isfinite(AP)) && all(isfinite(LAP)) && LAP(3) < 1 && LAP(4) < 1
      LAP(1) = AP(1) + Pos(1)*AP(3) - (LAP(3)*(Pos(3)+1)/2);
      LAP(2) = AP(2) + Pos(2)*AP(4) - (LAP(4)*(Pos(4)+1)/2);
      if all(isfinite(LAP))
        try
          set(H,'Position',LAP);
        catch
        end
      end
    end
    set(H,'Units','Points');
  end
end
set(f,'PaperUnits',FPU);
