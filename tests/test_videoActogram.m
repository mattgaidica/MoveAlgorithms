% setup
videoFile = 'exclude/MGhand_MoveAlgorithms-540p.mp4';
frameInterval = 1;
resizePx = 300;

% run
frameData = videoActogram(videoFile,frameInterval,resizePx);

% plot
figure('position',[0 0 700 300]);
plot(frameData(:,3),'lineWidth',2);

nticks = 10;
xtickMarks = floor(linspace(1,size(frameData,1),nticks));
xticks(xtickMarks);

% xticks
xticklabels(frameData(xtickMarks,1)); 
xlabel('frame');
% --- OR ---
xticklabels(compose('%3.2f',frameData(xtickMarks,2)));
xlabel('time (s)');

ylabel('\Delta pixels (arb. units)');
set(gcf,'color','w');
set(gca,'fontSize',16);

% also see: vout = overlayActogram(videoFile,frameData);