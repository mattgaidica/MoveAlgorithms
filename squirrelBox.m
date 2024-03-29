% Create a video reader.
obj.reader = VideoReader('/Users/matt/Downloads/JO.F.10.OFT_trim.mp4');

vid = {};
trainFrames = 20;
disp('Creating background estimation...');
for ii = round(linspace(1,obj.reader.NumFrames,trainFrames))
    vid{ii} = im2single(read(obj.reader,ii));
end
% background subsampled estimation
fgMask = mean(cat(4, vid{:}),4);

obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', true, 'CentroidOutputPort', true, ...
    'MinimumBlobArea', 400, 'MaximumCount', 1);

shapeInserter = vision.ShapeInserter('Shape','Rectangles',...
                                     'Fill', 1,...
                                     'FillColor','Custom',...
                                     'CustomFillColor', [255 0 0],...
                                     'Opacity', 0.2);
%%
close all
ff(1200,700);
allCenters = [];
obj.reader.CurrentTime = 0;
centerCount = 0;
distanceTraveled = 0;
c = jet(obj.reader.NumFrames);
v = VideoWriter('SquirrelOFT','MPEG-4');
open(v);
disp("Lets go");
fs = 16;
while hasFrame(obj.reader)
    frame = readFrame(obj.reader);
    
    mask = sum(abs(im2single(frame) - fgMask),3) > 0.25;
    mask = imopen(mask, strel('rectangle', [6,6]));
    mask = imclose(mask, strel('rectangle', [20,20]));
    mask = imfill(mask, 'holes');
    [~, centroids, bboxes] = obj.blobAnalyser.step(mask);
    if ~isempty(centroids)
        centerCount = centerCount + 1;
        allCenters(centerCount,:) = centroids;
    end
    shapeVid = shapeInserter(frame,bboxes);
    
    maskIm = uint8(mask(:,:,[1 1 1]) * 255);
    maskVid = shapeInserter(maskIm,bboxes);
    
    subplot(2,2,1);
    imshow(shapeVid);
    title(sprintf('Object Tracking (t = %1.2fs)',obj.reader.CurrentTime));
    set(gca,'fontsize',fs);
    
    subplot(2,2,2);
    imshow(maskVid);
    title('Mask');
    set(gca,'fontsize',fs);
    
    subplot(2,2,3);
    imshow(frame);
    hold on;
    scatter(allCenters(:,1),allCenters(:,2),20,c(1:centerCount,:),'Filled');
    hold off;
    xlim([1 size(frame,2)]);
    ylim([1 size(frame,1)]);
    title('All Centers');
    set(gca,'fontsize',fs);
    
    subplot(2,2,4);
    if centerCount > 1
        frameDistance = abs(pdist([allCenters(centerCount-1,:);allCenters(centerCount,:)]));
        distanceTraveled = distanceTraveled + frameDistance;
        yyaxis left;
        plot(centerCount,frameDistance,'k.');
        set(gca,'ycolor','k');
        ylabel('Frame Distance (px)');
        
        yyaxis right;
        plot(centerCount,distanceTraveled,'r.');
        set(gca,'ycolor','r');
        ylabel('Cum. Distance (px)');
        hold on;
    end
    ylabel('Cum. Distance (px)');
    xlabel('Frame');
%     xlim([1 obj.reader.NumFrames]);
    title('Pixels Traveled');
    set(gca,'fontsize',fs);
    
    f = getframe(gcf);
    writeVideo(v,f);
    drawnow;
end
close(v);