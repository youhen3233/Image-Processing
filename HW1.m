Image = imread('Bird feeding 3 low contrast.tif');

%Show idensity function figure
subplot(3,2,1.5,'align');
x = 0:1.0:255;
maxi = atan(double((255-128)/32));
mini = atan(double((0-128)/32));
f = atan( (x - 128) / 32 );   %indeinsity function
y = 255*(f - mini) / (maxi-mini);   %shifting & scaling H{}
plot(x,y);

%Show出第一張圖與直方圖
subplot(3,2,3,'align');
imshow(Image);
title('Input Image');

subplot(3,2,4,'align');
imhist(Image)
title('Input Image histogram');
opImage=Image;
% 進行矩陣轉換並產出輸出圖opImage
for i = 1 : size(opImage,1)
    for j = 1 : size(opImage,2)
        temp  = double(Image(i,j)) - 128;
        pixel = atan( ( double(temp) / 32 ) );
        opImage(i,j) =  (255 * (pixel - mini) ) / (maxi-mini);
    end
end

%Show出第二張圖與直方圖
subplot(3,2,5,'align');
imshow(opImage);
title('Output Image');

subplot(3,2,6,'align');
imhist(opImage)
title('Output Image histogram');

