%load('/home/camera3d/WORKS/MATLAB/3D_Construct_Matlab/calib_cam1_2_body_0.19_3Apr.mat');

K1 = stereoParams.CameraParameters1.IntrinsicMatrix';
K2 = stereoParams.CameraParameters2.IntrinsicMatrix';
D2 = [stereoParams.CameraParameters2.RadialDistortion(1:2), stereoParams.CameraParameters2.TangentialDistortion];
D1 = [stereoParams.CameraParameters1.RadialDistortion(1:2), stereoParams.CameraParameters1.TangentialDistortion];
R = stereoParams.RotationOfCamera2';
T = stereoParams.TranslationOfCamera2';

fileID = fopen('calibStereo3D.yml','w');

fprintf(fileID,'%%YAML:1.0 \n --- \n');

% K1
fprintf(fileID,'K1: !!opencv-matrix \n');
fprintf(fileID,'   rows: 3 \n');
fprintf(fileID,'   cols: 3 \n');
fprintf(fileID,'   dt: d \n');
fprintf(fileID,'   data: [ %f, %f, %f, \n', K1(1,1), K1(1,2), K1(1,3));
fprintf(fileID,'           %f, %f, %f, \n', K1(2,1), K1(2,2), K1(2,3));
fprintf(fileID,'           %f, %f, %f] \n', K1(3,1), K1(3,2), K1(3,3));

% K2
fprintf(fileID,'K2: !!opencv-matrix \n');
fprintf(fileID,'   rows: 3 \n');
fprintf(fileID,'   cols: 3 \n');
fprintf(fileID,'   dt: d \n');
fprintf(fileID,'   data: [ %f, %f, %f, \n', K2(1,1), K2(1,2), K2(1,3));
fprintf(fileID,'           %f, %f, %f, \n', K2(2,1), K2(2,2), K2(2,3));
fprintf(fileID,'           %f, %f, %f] \n', K2(3,1), K2(3,2), K2(3,3));

% D1
fprintf(fileID,'D1: !!opencv-matrix \n');
fprintf(fileID,'   rows: 1 \n');
fprintf(fileID,'   cols: 4 \n');
fprintf(fileID,'   dt: d \n');
fprintf(fileID,'   data: [ %f, %f, %f, %f ] \n', D1(1), D1(2), D1(3), D1(4));

% D2
fprintf(fileID,'D2: !!opencv-matrix \n');
fprintf(fileID,'   rows: 1 \n');
fprintf(fileID,'   cols: 4 \n');
fprintf(fileID,'   dt: d \n');
fprintf(fileID,'   data: [ %f, %f, %f, %f ] \n', D2(1), D2(2), D2(3), D2(4));

% R
fprintf(fileID,'R: !!opencv-matrix \n');
fprintf(fileID,'   rows: 3 \n');
fprintf(fileID,'   cols: 3 \n');
fprintf(fileID,'   dt: d \n');
fprintf(fileID,'   data: [ %f, %f, %f, \n', R(1,1), R(1,2), R(1,3));
fprintf(fileID,'           %f, %f, %f, \n', R(2,1), R(2,2), R(2,3));
fprintf(fileID,'           %f, %f, %f] \n', R(3,1), R(3,2), R(3,3));

% T
fprintf(fileID,'T: [ %f, %f, %f ] \n', T(1), T(2), T(3));

fclose(fileID);