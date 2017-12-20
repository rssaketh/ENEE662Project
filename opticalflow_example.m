main_path = 'example_images/car/';
path_g = sprintf('%sgray',main_path);

opticFlow = opticalFlowLK('NoiseThreshold',0.009);
figure();
for i = 1 : 4
    gI = imread(sprintf('%s/output-%d.jpg',path_g,i));
    gI = double(gI)/255;
    frameGray1 = rgb2gray(gI);

    flow = estimateFlow(opticFlow,frameGray1);

    imshow(gI)
    hold on
    %plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    plot(flow)
    hold off
    pause(1)
end
figure();
for i = 1 : 4
    gI = imread(sprintf('%s/output-%d.jpg',path_g,i));
    gI = double(gI)/255;
    %frameGray = rgb2gray(gI);
    frameGray2 = gI(:,:,1);

    flow = estimateFlow(opticFlow,frameGray2);

    imshow(gI)
    hold on
    %plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    plot(flow)
    hold off
    pause(1)
end