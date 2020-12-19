% Clear all command window, temporary variables and close all MATLAB  window 
clear; close all; clc; 
% Read the image, data type: uint8 [0, 255] 
Img = double(imread('Car On Mountain Road.tif'));
[M,N] = size(Img);
%figure(1); imshow(uint8(Img));title('Original Image'); 
%%-----------------------------------------------------------------------------
%marr-Hildreth setp-by-step
%%Marr-Hildreth  Gaussian LPF
%Design the Gaussian Kernel
%Standard Deviation
sigma = 1.5;

%Window size
sz = 4;
[x,y]=meshgrid(-sz:sz,-sz:sz);

M1 = size(x,1)-1;
N1 = size(y,1)-1;
Exp_comp = -(x.^2+y.^2)/(2*sigma*sigma);
Kernel= exp(Exp_comp)/(2*pi*sigma*sigma);

%Initialize
Img_lpf=zeros(size(Img));
%Pad the vector with zeros
Img = padarray(Img,[sz sz]);

%Convolution
for i = 1:size(Img,1)-M1
    for j =1:size(Img,2)-N1
        Temp = Img(i:i+M1,j:j+M1).*Kernel;
        Img_lpf(i,j)=sum(Temp(:));
    end
end
%figure(2);         imshow(uint8(Img_lpf));           title('Gaussizn LPF ') ;
%%-----------------------------------------------------------------------------
%%Marr-Hildreth  Laplacian operation
Laplace = [-1 -1 -1;-1 8 -1; -1 -1 -1];
Img_LOG = conv2(Img_lpf,Laplace);
LOG_O = Img_LOG(2:701,2:1101);
%figure(3);         imshow(uint8(LOG_O));           title('LOG Image') ;
%{   套件式作法，用於驗算
%Log_filter = fspecial('gaussian', [5,5], 4.0); % fspecial creat predefined filter.Return a filter. 25X25 Gaussian filter with SD =25 is created.
%G_Img = Img .* Log_filter;
%figure(2);         imshow(G_Img,[]);         title('LOG Img') ;

%Img_LOG = imfilter(Img, Log_filter, 'symmetric', 'conv');
%figure(2);         imshow(Img_LOG,[]);         title('LOG Img') ;
%}
%%-----------------------------------------------------------------------------
%%Marr-Hildreth  ZeroCrossing
Zero_0 = ones(M,N);
Img_LOG = Img_LOG / 255;
thr = 0. *max(max(Img_LOG) ); 
for r = 1:M
    for c = 1:N
        flag = 0;
        condition = Img_LOG(r:r+2,c:c+2);
        % 1
        if ((condition(1,1)*condition(3,3)<0) && ( abs(condition(1,1)-condition(3,3))>=thr))
            Zero_0(r,c) = 255;
        end
        % 2
        if ((condition(1,3)*condition(3,1)<0) && ( abs(condition(1,3)-condition(3,1))>=thr))
            Zero_0(r,c) = 255;
        end
        % 3
        if ((condition(1,2)*condition(3,2)<0) && ( abs(condition(1,2)-condition(3,2))>=thr))
            Zero_0(r,c) = 255;
        end
        % 4
        if ((condition(2,1)*condition(2,3)<0) && ( abs(condition(2,1)-condition(2,3))>=thr))
            Zero_0(r,c) = 255;
        end
    end
end
%figure(4);         imshow(uint8(Zero_0));           title('Zero crossing-Threshold == 0') ;

Zero_4 = ones(M,N);
Img_LOG = Img_LOG / 255;
thr = 0.04 *max(max(Img_LOG) ); 
for r = 1:M
    for c = 1:N
        flag = 0;
        condition = Img_LOG(r:r+2,c:c+2);
        % 1
        if ((condition(1,1)*condition(3,3)<0) && ( abs(condition(1,1)-condition(3,3))>=thr))
            Zero_4(r,c) = 255;
        end
        % 2
        if ((condition(1,3)*condition(3,1)<0) && ( abs(condition(1,3)-condition(3,1))>=thr))
            Zero_4(r,c) = 255;
        end
        % 3
        if ((condition(1,2)*condition(3,2)<0) && ( abs(condition(1,2)-condition(3,2))>=thr))
            Zero_4(r,c) = 255;
        end
        % 4
        if ((condition(2,1)*condition(2,3)<0) && ( abs(condition(2,1)-condition(2,3))>=thr))
            Zero_4(r,c) = 255;
        end
    end
end
%figure(5);         imshow(uint8(Zero_4));           title('Zero crossing-Threshold == 4') ;
%%-----------------------------------------------------------------------------
%Hough parameter space
%二質化
hough_array = Zero_4;
for i = 1:M
    for j =1:N
        if hough_array(i,j) == 1            
            hough_array(i,j) = 0;
        else
            hough_array(i,j) = 1;
        end
    end
end

[H,T,R] = hough(hough_array,'RhoResolution',1,'Theta',-90:1:89);
figure(6);
imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit'); 
title('Hough transform of Zero-crossing for 4% threshold');    xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on

P  = houghpeaks(H,8);
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');
%%-----------------------------------------------------------------------------
%Figure of linked edges alone
lines = houghlines(hough_array,T,R,P,'FillGap',5,'MinLength',7);
Background = zeros(M,N);
figure(7), imshow(Background), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
%FIgure of linked edges overlapped
figure(8), imshow(hough_array), hold on

for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
