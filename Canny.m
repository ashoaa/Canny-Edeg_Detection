clc
close all
clear
% loading image
img = imread('airport.tif');
img = double(img);
[m,n] = size(img);
filt = [1,2,1;2,4,2;1,2,1]/16;
img_f = img;
% filtering image
for i = 2:m-1
    for j = 2:n-1
        t = img(i-1:i+1,j-1:j+1).*filt;
        img_f(i,j) = sum(t(:));
    end
end
s = [1,2,1;0,0,0;-1,-2,-1];
gx = img_f;
gy = img_f;
% calculating gradient
for i = 2:m-1
    for j = 2:n-1   
        t1 = img_f(i-1:i+1,j-1:j+1).*s;
        t2 = img_f(i-1:i+1,j-1:j+1).*s';
        % gradient in x direction
        gx(i,j) = sum(t1(:));
        % gradient in y direction
        gy(i,j) = sum(t2(:));
    end
end
mag = sqrt(gx.^2 + gy.^2);
% direction of gradient
direct = atan2d(gy,gx)+180;
% making non-maximum suppressed image
img_nms = zeros(m,n);
for i = 2:m-1
    for j = 2:n-1
        % 0 and 180 degrees direction
        if (direct(i,j) > 0 && direct(i,j) <= 22.5) || (direct(i,j) > 157.5 && direct(i,j) <= 202.5)
            if mag(i,j) >= mag(i-1,j) && mag(i,j) >= mag(i+1,j)
                img_nms(i,j) = mag(i,j);
            end
        % 45 and 225 degrees direction
        elseif (direct(i,j) > 22.5 && direct(i,j) <= 67.5) || (direct(i,j) > 202.5 && direct(i,j) <= 247.5)
            if mag(i,j) >= mag(i-1,j-1) && mag(i,j) >= mag(i+1,j+1)
                img_nms(i,j) = mag(i,j);
            end   
        % 90 and 270 degrees direction
        elseif (direct(i,j) > 67.5 && direct(i,j) <= 112.5) || (direct(i,j) > 247.5 && direct(i,j) <= 295.5)
            if mag(i,j) >= mag(i,j-1) && mag(i,j) >= mag(i,j+1)
                img_nms(i,j) = mag(i,j);
            end
        % 135 and 315 degrees direction
        else
            if mag(i,j) >= mag(i-1,j+1) && mag(i,j) >= mag(i+1,j-1)
                img_nms(i,j) = mag(i,j);
            end
        end
    end
end
% double thresholding
th_l = 20;
th_h = 40;
img_l = img_nms>th_l;
img_h = img_nms>th_h;
img_ed = zeros(m,n);
% linking edges
for i = 1:m
    for j = 1:n
        if img_h(i,j)==1
            img_ed(i-1:i+1,j-1:j+1) = img_l(i-1:i+1,j-1:j+1); 
        end
    end
end
ed = edge(img,'canny');
figure
imshow(img/255)
title('original image')
figure
imshow(mag,[])
title('magnitude image')
figure
imshow(img_nms,[])
title('nonmaxima suppressed image')
figure
imshow(img_ed)
title('final image')
figure
imshowpair(img_ed,ed,'montage')
title('implemented canny vs built-in function')