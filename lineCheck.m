function res = lineCheck(X,A,B)
    x = X(1);y = X(2); xA = A(2); yA = A(1); xB = B(2); yB = B(1);
    res = (x - xA)/(xB-xA) -  (y - yA)/(yB - yA);
end