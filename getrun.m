function run = getrun(noheader, co)
% run = getrun([noheader])
%  Extracts the run from the current working directory.
if nargin < 2
    co = gcbo;
    if nargin < 1
      noheader = 0;
    end
end
run = getrundir(co);
m = max(findstr(filesep,run))+1;
run = run([m:length(run)]);
if noheader == 0
  if run(length(run)) == 'F'
    run = [ 'Flight ' run(1:length(run)-1) ];
  else
    run = [ 'Run ' run ];
  end
elseif run(length(run)) == 'F'
  run = run(1:length(run)-1);
end
