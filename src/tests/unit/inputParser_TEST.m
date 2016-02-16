function [results] = inputParser_TEST(source, target, varargin)
p = inputParser;

addRequired(p, 'source');
addRequired(p, 'target');
addParameter(p, 'windowLength', 50);
addParameter(p, 'overlap', 25);
addParameter(p, 'fs', 44100);

parse(p, source, target, varargin{:});

results = p.Results;

end