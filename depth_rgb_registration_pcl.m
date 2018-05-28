function [aligned] = ...
                    depth_rgb_registration_pcl(pointCloud, rgbData,...
                    fx_rgb, fy_rgb, cx_rgb, cy_rgb,...
                    extrinsics)
 
    depthHeight = size(pointCloud, 1);
    depthWidth = size(pointCloud, 2);
    rgbHeight = size(rgbData, 1);
    rgbWidth = size(rgbData, 2);
    %figure;imshow(depthData);
    % Aligned will contain X, Y, Z, R, G, B values in its planes
    aligned = zeros(depthHeight, depthWidth, 6);
 
    for v = 1 : (depthHeight)
        for u = 1 : (depthWidth)
            % Apply depth intrinsics
            x = single(pointCloud(v,u,1));
            y = single(pointCloud(v,u,2));
            z = single(pointCloud(v,u,3));
            
            
            % Apply the extrinsics
            transformed = (extrinsics * [x;y;z;1])';
            aligned(v,u,1) = transformed(1);
            aligned(v,u,2) = transformed(2);
            aligned(v,u,3) = transformed(3);
        end
    end
    for v = 1 : (depthHeight)
        for u = 1 : (depthWidth)
            % Apply RGB intrinsics
            x = (aligned(v,u,1) * fx_rgb / aligned(v,u,3)) + cx_rgb;
            y = (aligned(v,u,2) * fy_rgb / aligned(v,u,3)) + cy_rgb;
            
            % "x" and "y" are indices into the RGB frame, but they may contain
            % invalid values (which correspond to the parts of the scene not visible
            % to the RGB camera.
            % Do we have a valid index?
            
            if (x > rgbWidth || y > rgbHeight ||...
                x < 1 || y < 1 ||...
                isnan(x) || isnan(y))
                continue;
            end
            
            % Need some kind of interpolation. I just did it the lazy way
            x = round(x);
            y = round(y);
            %disp('xx');
            aligned(v,u,4) = single(rgbData(y, x, 1));
            aligned(v,u,5) = single(rgbData(y, x, 2));
            aligned(v,u,6) = single(rgbData(y, x, 3));
        end
    end    
end