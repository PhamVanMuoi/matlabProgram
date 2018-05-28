%% Clear variables, figures and screen
clear;
close all;
clc;
%% Create near GT
imgL = imread('22May_evaluation/Cam1/00009.png');
imgR = imread('22May_evaluation/Cam2/00009.png');
load('22May_calib1/calib_22May.mat');
[imgLRect, imgRRect] = rectifyStereoImages(imgL, imgR, stereoParams);
imwrite(imgLRect,'L_rec.png');
imwrite(imgRRect,'R_rec.png');
figure;imshow(stereoAnaglyph(imgLRect, imgRRect));
%%%%%% Calculate disparity with SGM %%%%%%%%%%%%%
imgLGray  = rgb2gray(imgLRect);
imgRGray = rgb2gray(imgRRect);
%%
range = [0 1280];
disparityMap = disparity(imgLGray, imgRGray,'Method','SemiGlobal','BlockSize',15,'DisparityRange',range);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Calculate near GT disparity %%%%%%%%%%%
imgL = imread('22May_evaluation/Cam1/00009.png');
imgR = imread('22May_evaluation/Cam2/00009.png');
[imgLRect, imgRRect] = rectifyStereoImages(imgL, imgR, stereoParams);
[pointL,a1,a2]= detectCheckerboardPoints(imgLRect);
[pointR,a3,a4]= detectCheckerboardPoints(imgRRect);
near_GT1 = pointL - pointR;
near_GT = near_GT1(:,1);
X = round(pointL(:,1));
Y = round(pointL(:,2));
A = round(pointL(1,:));
B = round(pointL(7,:));
C = round(pointL(57,:));
D = round(pointL(63,:));

left = min(X);
right = max(X);
top = min(Y);
bot = max(Y);
[X1,Y1] = meshgrid(left:right,(top:bot));
F = scatteredInterpolant(X,Y,near_GT,'natural');
V = F(X1,Y1);
dis_GT = double(imgLRect(:,:,1));
s = size(dis_GT);
%% 
avaiPoint = 0;
sumPoint = 0;

for i=1:s(1)
    for j=1:s(2)
        %if ((i > top) && (i < bot) && (j > left) && (j > right))
        %    dis(i,j) = V(i-top,j-left);
        %else
        %    dis(i,j) = 0;
        %end
        X_po = [i j];
        top_ = lineCheck(X_po,A,C);
        left_ = lineCheck(X_po,A,B);
        bot_ = lineCheck(X_po,B,D);
        right_ = lineCheck(X_po,C,D);
        %if (right_ > 0)
        %    dis(i,j) = 1;
        %else dis(i,j) = 0;
        %end
        if ((top_ < 0) && (bot_ > 0) && (left_ > 0) && (right_ > 0))
            dis_GT(i,j) = V(i-top,j-left);
            sumPoint = sumPoint + 1;
            if(disparityMap(i,j)> 0)
                avaiPoint = avaiPoint + 1;
            end
        else
            dis_GT(i,j) = 0;
            disparityMap(i,j) = 0;
        end
%         if ((i > top) && (i < bot) && (j > left) && (j < right))
%             dis_GT1(i,j) = V(i-top,j-left);
%         else
%             dis_GT1(i,j) = 0;
%         %    disparityMap(i,j) = 0;
%         end
    end
end
figure;
subplot(121);imshow(dis_GT);title('Near Ground Truth');
subplot(122);imshow(disparityMap);title('Disparity map with SGM');

%% Show 3D point cloud
points3D1 = reconstructScene(dis_GT, stereoParams);
points3D1 = points3D1 ./ 1000;
points3D = reconstructScene(disparityMap, stereoParams);
points3D = points3D ./ 1000;

x1 = imgLRect; x1(:,:) = 0;
ptCloud1 = pointCloud(points3D1, 'Color',x1);
% depthMap = points3D(:,:,3);

% Create a streaming point cloud viewer
player3D1 = pcplayer([-1, 1], [-1, 1], [0, 3], 'VerticalAxis', 'y', ...
    'VerticalAxisDir', 'down');

% Visualize the point cloud
view(player3D1,ptCloud1);
xx = [X Y];
for i = 1:63
x(i) = points3D1(xx(i,2),xx(i,1),1);
y(i) = points3D1(xx(i,2),xx(i,1),2);
z(i) = points3D1(xx(i,2),xx(i,1),3);
end
x = x(~isinf(x));
y = y(~isinf(y));
z = z(~isinf(z));
x = transpose(x);
y = transpose(y);
z = transpose(z);
[a,b,c]=plane_fit(x,y,z);

x1 = points3D(:,:,1);
y1 = points3D(:,:,2);
z1 = points3D(:,:,3);
x1 = x1(~isinf(x1));
y1 = y1(~isinf(y1));
z1 = z1(~isinf(z1));
x1 = x1(~isnan(x1));
y1 = y1(~isnan(y1));
z1 = z1(~isnan(z1));
x1 = x1((z1 > 0.2) & (z1 < 1));
y1 = y1((z1 > 0.2) & (z1 < 1));
z1 = z1((z1 > 0.2) & (z1 < 1));
distance = distance_plane(x1,y1,z1,a,b,c);
distance = distance.^2;
res = sqrt(mean2(distance))*1000;
fprintf('Available: %d/%d = %f\n',[avaiPoint sumPoint avaiPoint/sumPoint]);
fprintf('Standard deviation: %f mm\n',res);

