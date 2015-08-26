d = 0:0.5:40;
v = 0:.5:10;
[I1,I2] = meshgrid(d,v);
%I = [I1(:),I2(:)];
[r,c] = size(I1);
L = r*c;
out = zeros(r,c);


for k = 1:L
    
    i1 = I1(k);
    i2 = I2(k);
    %(sin((i1+i2)/20*1*pi))^2 +(i1+i2)*1/5;
    %a = (sin(i1/10*1*pi))^2 + (sin(i2/10*1*pi))^2 + (i1+i2)*1/5;
    
%     c = 0;
%     if (i1 <= 15) && (i2 <= 3)
%         f = (sin(i1/80*pi)) - (sin(i2/20*pi));
%         c=1;
%     elseif (15 < i1 && i1 <= 25) && (3 < i2 && i2 <= 7) || 
%         f = (sin(i1/80*pi)) - (sin(i2/20*pi));
%         c=2;
%     else
%         f = 2;
%        c=3;
%     end
%     C(k)= c;
    f = (((- sin(i1/80*pi)) + (sin(i2/20*pi))) + 1)/2*255;
    out(k) = f;
end

surfc(I2,I1,out);
