%% Config paramters
f_rgb = IRR.CameraParameters2.FocalLength;
c_rgb = IRR.CameraParameters2.PrincipalPoint;
f_dL = stereoParams.CameraParameters1.FocalLength;
c_dL = stereoParams.CameraParameters1.PrincipalPoint;

f_dR = stereoParams.CameraParameters1.FocalLength;
c_dR = stereoParams.CameraParameters1.PrincipalPoint;

R1 = IRL.RotationOfCamera2;
T1 = IRL.TranslationOfCamera2;

R3 = stereoParams.RotationOfCamera2;
T3 = stereoParams.TranslationOfCamera2;

R2 = IRR.RotationOfCamera2;
T2 = IRR.TranslationOfCamera2;

xxx1 =  [R1' -T1'; 0 0 0 1]';


xxx2 =  [R2' -T2'; 0 0 0 1]';

  
xxx3 = [(R3)' (-T3'); 0 0 0 1]';
%% Run 1
[all1] = depth_rgb_registration(depthMap,Rec2 ,f_dL(1),f_dL(2),c_dL(1),c_dL(2),f_rgb(1),f_rgb(2),c_rgb(1),c_rgb(2),xxx1);
figure;imshow(uint8(all1(:,:,4:6)));
%% Run 2
[all2] = depth_rgb_registration(depthMap,Rec2 ,f_dR(1),f_dR(2),c_dR(1),c_dR(2),f_rgb(1),f_rgb(2),c_rgb(1),c_rgb(2),xxx2);
figure;imshow(uint8(all2(:,:,4:6)));
%% Run 3
[all3] = depth_rgb_registration(depthMap,frameRightRect ,f_dL(1),f_dL(2),c_dL(1),c_dL(2),f_rgb(1),f_rgb(2),c_rgb(1),c_rgb(2),xxx3);
figure;imshow(uint8(all3(:,:,4:6)));
%% Run 4
[all4] = depth_rgb_registration_pcl(points3D,Rec2,f_rgb(1),f_rgb(2),c_rgb(1),c_rgb(2),xxx1);
figure;imshow(uint8(all4(:,:,4:6)));