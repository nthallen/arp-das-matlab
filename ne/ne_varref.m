function [ ref, Tref ] = ne_varref( vars, reqd, i )
% ref = ne_varref( vars, reqd, i )
% [ ref, Tref ] = ne_varref( vars, reqd, i );
% returns a text string for accessing the specified variable.
% reqd is a cell array returned by findvar(). i is an index
% into that array. If Tref is specified, it will be the
% reference string associated with the appropriate time
% variable.
arcvar = reqd{i};
delim = max(findstr( arcvar, '\' ));
if ~isempty(delim)
  arcvar = arcvar([delim+1:length(arcvar)]);
end
ref = [ arcvar '.' vars{i} ];
if nargout > 1
  Tref = [ arcvar '.T' ];
end
