function lines = ne_readlines(fname)
  % lines = ne_readlines(fname);
  if ne_isOctave
    fid = fopen(fname);
    nlines = 0;
    ncells = 100;
    lines = cell(ncells,1);
    while true
      newlabel = fgetl(fid);
      if ~isempty(newlabel)
        if isnumeric(newlabel) && newlabel < 0
          break;
        else
          nlines = nlines+1;
          if nlines > ncells
            ncells = ncells*2;
            lines = ne_cell_resize(lines, ncells);
          end
          lines{nlines} = newlabel;
        end
      end % else skip blank line (common at end of file)
    end
    lines = ne_cell_resize(lines, nlines);
  else
    lines = readlines(fname, 'EmptyLineRule','skip');
  end
end

function ocell = ne_cell_resize(icell, N)
  % ocell = ne_cell_resize(icell, N);
  icell_len = length(icell);
  if icell_len >= N % truncation operation
    ocell = icell(1:N);
  else % reallocation
    ocell = cell(N,1);
    ocell(1:icell_len) = icell;
  end
end
