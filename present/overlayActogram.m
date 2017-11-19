function vout = overlayActogram(videoFile,frameData)
nticks = 10;
xtickMarks = floor(linspace(1,size(frameData,1),nticks));

v = VideoReader(videoFile);
[pathstr,name,ext] = fileparts(videoFile);

processedPath = fullfile(pathstr,[name,'_overlayActogram']);
vout = VideoWriter(processedPath,'MPEG-4');
vout.Quality = 95;
open(vout);

h = figure('position',[0 0 800 800]);
curFrame = 1;
frameCount = 1;
while hasFrame(v)
    frame = readFrame(v);
    if ismember(curFrame,frameData(:,1))
        subplot(211);
        imshow(frame);
        
        subplot(212);
        plot(frameData(:,3),'lineWidth',2);
        hold on;
        plot(frameCount,frameData(frameCount,3),'r.','markerSize',20);
        hold off;
        xticklabels(compose('%3.2f',frameData(xtickMarks,2)));
        xlabel('time (s)');
        ylabel('\Delta pixels (arb. units)');
        set(gcf,'color','w');
        set(gca,'fontSize',16);
        
        fullframe = getframe(h);
        writeVideo(vout,fullframe);
        frameCount = frameCount + 1;
    end
    curFrame = curFrame + 1;
end
close(h);
close(vout);