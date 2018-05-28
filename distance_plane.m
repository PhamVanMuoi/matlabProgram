function res = distance_plane(x,y,z,a,b,c)
    for i=1:size(x)
        res(i) = abs(a*x(i) + b*y(i) - z(i) + c)/sqrt(a^2 + b^2 + 1);
    end
end