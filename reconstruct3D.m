tic;
close all;
clc;clear;

%load('CalibParameter/22Feb_calib_camIR_LR_0.17.mat');
load('/home/vp9/WORKS/SmartCam/Calibration_28Feb/smartCam_28Feb_0.17.mat');
%load('newCam_5Feb.mat');
%stereoParams = stereoParams;
%imgL = imread('/home/ntddung/WORK/getDataCam/Left/0001.jpg');
%imgR = imread('/home/ntddung/WORK/getDataCam/Right/0001.jpg');
%imgL = imread('/home/vp9/WORKS/SmartCam/Images_1Mar/Left/1519874150779.jpg');
%imgR = imread('/home/vp9/WORKS/SmartCam/Images_1Mar/Right/1519874150808.jpg');
%imgRGB = imread('/home/vp9/Test/IR_Cam_Blink/008/Left/00026.png');
imgL = imread('Left/001.jpg');
imgR = imread('Right/001.jpg');
%imgL = imread('/home/vp9/Improve/10/Stereo Vision 1/50pattern50.jpg');
%imgR = imread('/home/vp9/Improve/10/Stereo Vision 2/50pattern50.jpg');
%imgR1 = imread('/home/vp9/Test/GetData/Right_Feb10/Right_0pattern.png');
%imgL = imread('/home/ntddung/WORK/getDataCam/Good_CheckBoard/Left/0000.jpg');
%imgR = imread('/home/ntddung/WORK/getDataCam/Good_CheckBoard/Right/0000.jpeg');
[frameLeftRect, frameRightRect] = rectifyStereoImages(imgL, imgR, stereoParams);
%[imgOp, noUse] = rectifyStereoImages(imgRGB, imgR, stereoParams);
%[Rec1, Rec2] = rectifyStereoImages(imgL, imgRGB, IRL);
%frameLeftRect=frameLeftRect(341:823,914:1460,:);
%frameRightRect=frameRightRect(341:823,914:1460,:);
%[frameLeftRect1, frameRightRect2] = rectifyStereoImages(imgL, imgR1, stereoParams);
%imwrite(frameLeftRect, 'left_trung.jpg');
%imwrite(frameRightRect,'right_trung.jpg');
%xxx = imtranslate(Rec2,[-110, 0],'OutputView','same');
figure;

%title('Rectified Video Frames');
%%
frameLeftGray  = rgb2gray(frameLeftRect); 
frameRightGray = rgb2gray(frameRightRect); 
%Rec1 = rgb2gray(Rec1);Rec2 = rgb2gray(Rec2);
imshow(stereoAnaglyph(frameLeftGray, frameRightGray));
range = [0 480];%[0 1280];%[64 160];
%range = [-64 160];
%disparityMap = disparity(Rec1, Rec2,'Method','SemiGlobal','BlockSize',15,'DisparityRange',range);
disparityMap = disparity(frameLeftGray, frameRightGray,'Method','SemiGlobal','BlockSize',15,'DisparityRange',range);
%disparityMap = disparity(frameLeftGray, frameRightGray,'Method','Blockmatching','BlockSize',15,'DisparityRange',range);
%disparityMap = imgaussfilt(disparityMap);
%disparityMap = medfilt2(disparityMap);
%disparityMap = medfilt2(disparityMap);
% disparityMapInter = interp2(disparityMap,5);
figure;
imshow(disparityMap);
title('Disparity Map');
%dis = single(rgb2gray(imgL));dis(:,:)=0;dis(341:823,914:1460) = disparityMap;

points3D = reconstructScene(disparityMap, stereoParams);

% Convert to meters and create a pointCloud object
points3D = points3D ./ 1000;
depthMap = points3D(:,:,3);%sqrt(points3D(:,:,1).^2 + points3D(:,:,2).^2 + points3D(:,:,3).^2);
points3D(depthMap>.75) = NaN;
points3D(depthMap<.55) = NaN;
tmp = points3D(:,:,3);
points3D(:,:,3) = tmp;
x = frameLeftRect; x(:,:) = 0;
%x = Rec1;% x(:,:)=0;
ptCloud1 = pointCloud(points3D, 'Color',x);
% depthMap = points3D(:,:,3);

% Create a streaming point cloud viewer
player3D1 = pcplayer([-1, 1], [-1, 1], [-1, 1], 'VerticalAxis', 'y', ...
    'VerticalAxisDir', 'down');

% Visualize the point cloud
view(player3D1,ptCloud1);
%pcwrite(ptCloud1,'Blink_cam/008.ply');
%imwrite(imgOp,'Blink_cam/008.png');
% View depth map
figure;imshow(depthMap);
% depthMap = depthMap .* 255;
% figure;imshow(depthMap);
%[point,b] = detectCheckerboardPoints(frameLeftRect);
%interestImg = depthMap(point(1,2):point(99,2),point(1,1):point(99,1));
%figure;imshow(interestImg);
%x = averageDepth(interestImg)
toc;
