% http://people.csail.mit.edu/mrub/evm/#code
dataDir = '/Users/matt/Documents/MATLAB/MoveAlgorithms/EVM13/data';
resultsDir = '/Users/matt/Documents/MATLAB/MoveAlgorithms/EVM13/data';

inFile = fullfile(dataDir,'46_small.mov');
fprintf('Processing %s\n', inFile);

samplingRate = 10; % Hz
loCutoff = 0.5;    % Hz
hiCutoff = 3;    % Hz
alpha = 100;    
sigma = 10;         % Pixels
pyrType = 'octave';

scaleAndClipLargeVideos = false;
defaultPyrType = 'halfOctave';

if (scaleAndClipLargeVideos)
    phaseAmplify(inFile, alpha, loCutoff, hiCutoff, samplingRate, resultsDir,'sigma', sigma,'pyrType', pyrType, 'scaleVideo', 0.4);
else
    phaseAmplify(inFile, alpha, loCutoff, hiCutoff, samplingRate, resultsDir,'sigma', sigma,'pyrType', pyrType, 'scaleVideo', 1);
end