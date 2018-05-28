tic;
close all;
clc;clear;
% Load parameters
load('CalibParameter/LRGB_23Feb_skew_distortion.mat');
IRL = stereoParams;
load('CalibParameter/LR_23Feb_skew_distortion.mat');
% Load images
imgL = imread('/home/vp9/Test/GetData/FinalDay_v1_12Feb/Left/00001.png');
imgR = imread('/home/vp9/Test/GetData/FinalDay_v1_12Feb/Right/00001.png');
img = imread('/home/vp9/Test/GetData/FinalDay_v1_12Feb/RGB/00001.png');
imgRGB(:,:,1) = img ;imgRGB(:,:,2) = img;imgRGB(:,:,3) = img;

% Rectify images
[frameLeftRect, frameRightRect] = rectifyStereoImages(imgL, imgR, stereoParams);
[Rec1, Rec2] = rectifyStereoImages(imgL, imgRGB, IRL);



frameLeftGray  = rgb2gray(frameLeftRect); 
frameRightGray = rgb2gray(frameRightRect); 
%Rec1 = rgb2gray(Rec1);Rec2 = rgb2gray(Rec2);
figure;
imshow(stereoAnaglyph(frameLeftGray, frameRightGray));
range = [0 480];%[0 1280];%[64 160];
%range = [-64 160];
% compute disparity
disparityMap = disparity(frameLeftGray, frameRightGray,'Method','SemiGlobal','BlockSize',15,'DisparityRange',range);

figure;
imshow(disparityMap);
title('Disparity Map');
%dis = single(rgb2gray(imgL));dis(:,:)=0;dis(341:823,914:1460) = disparityMap;

% Create point cloud 
points3D = reconstructScene(disparityMap, stereoParams);

% Convert to meters and create a pointCloud object
points3D = points3D ./ 1000;
%Calculate depth map 
depthMap = points3D(:,:,3);%sqrt(points3D(:,:,1).^2 + points3D(:,:,2).^2 + points3D(:,:,3).^2);

% Calculate paramters for aligning
R1 = IRL.RotationOfCamera2;
T1 = IRL.TranslationOfCamera2;
f_rgb = IRL.CameraParameters2.FocalLength;
c_rgb = IRL.CameraParameters2.PrincipalPoint;
f_dL = stereoParams.CameraParameters1.FocalLength;
c_dL = stereoParams.CameraParameters1.PrincipalPoint;
extrins =  [R1' -T1'; 0 0 0 1]';

% Aligning 
[all1] = depth_rgb_registration(depthMap,Rec2 ,f_dL(1),f_dL(2),c_dL(1),c_dL(2),f_rgb(1),f_rgb(2),c_rgb(1),c_rgb(2),extrins);

% Get image
imageOP = uint8(all1(:,:,4:6));


points3D(depthMap>.75) = NaN;
points3D(depthMap<.35) = NaN;
tmp = points3D(:,:,3);
points3D(:,:,3) = tmp;
x = frameLeftRect;% x(:,:) = 0;
%x = Rec1;% x(:,:)=0;
ptCloud1 = pointCloud(points3D, 'Color',imageOP);
% depthMap = points3D(:,:,3);

% Create a streaming point cloud viewer
player3D1 = pcplayer([-1, 1], [-1, 1], [-1, 1], 'VerticalAxis', 'y', ...
    'VerticalAxisDir', 'down');

% Visualize the point cloud
view(player3D1,ptCloud1);
pcwrite(ptCloud1,'pointCloud.ply'); % write point cloud to open with meshlab 
% View depth map
figure;imshow(depthMap);
% depthMap = depthMap .* 255;
% figure;imshow(depthMap);
%[point,b] = detectCheckerboardPoints(frameLeftRect);
%interestImg = depthMap(point(1,2):point(99,2),point(1,1):point(99,1));
%figure;imshow(interestImg);
%x = averageDepth(interestImg)
toc;
