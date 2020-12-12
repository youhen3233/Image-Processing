% Clear all command window, temporary variables and close all MATLAB  window 
clear; close all; clc; 
% Read the image, data type: uint8 [0, 255] 
Img=imread('Bird 3 blurred.tif'); 
% Change the image type to double and normalize to [0, 1] Img=im2double(Img); 
%figure; imshow(Img);title('Original Image'); 
Img=im2double(Img); 
%-------------------------------------------------------------
% Extract the RGB value of the image 
R = Img(:,:,1); 
G = Img(:,:,2); 
B = Img(:,:,3); 
% Plot the image of R component 
figure; imshow(R);title('R Image'); 
% Plot the image of G component 
figure; imshow(G);title('G Image'); 
% Plot the image of B component 
figure; imshow(B);title('B Image'); 
%----------------------------------------------------------
% Converting Colors from RGB to HSI,  
% H component of each RGB pixel is obtained using the equation in  lecture note 
th=acos((0.5.*((R-G)+(R-B))) ./ ((sqrt((R-G).^2+(R-B).*(G-B))))); H=th; 
H(B>G)=2*pi-H(B>G); 
H=H/(2*pi); 
% S component of each RGB pixel is obtained using the equation in  lecture note 
S=1-3.*(min(min(R,G),B))./(R+G+B); 
% I component of each RGB pixel is obtained using the equation in  lecture note 
I=(R+G+B)/3; 
% Plot the image of H component 
figure; imshow(H); title('H Image'); 
% Plot the image of S component 
figure; imshow(S); title('S Image'); 
% Plot the image of I component 
figure; imshow(I); title('I Image'); 
%----------------------------------------------------------------------
% RGB Sharpen & difference
Img_S =  imsharpen(Img,'Radius',2,'Amount',4);
figure; imshow(Img_S);title('Sharppen Image'); 
Differ_RGB = Img_S - Img;
figure; imshow(Differ_RGB);title('RGB Image Sharppen Difference');
%----------------------------------------------------------------------
% HSI Sharpen & difference
HSI_Image = imread('Bird 3 blurred.tif'); 
HSI_Image = im2double(HSI_Image); 
Filter=[-1 -1 -1;-1 8 -1; -1 -1 -1];

H_C = conv2(H_Gra,Filter);
S_C = conv2(S_Gra,Filter);
I_C = conv2(I_Gra,Filter);

H_S = H_C(2:801,2:1201);
S_S = S_C(2:801,2:1201);
I_S = I_C(2:801,2:1201);

HSI_Image(:,:,1) = H_S; 
HSI_Image(:,:,2) = S_S;
HSI_Image(:,:,3) = I_S;


%difference
HSI_F = hsi2rgb(HSI_Image);
%output
Img_HSI_S = Img - HSI_F;

figure; imshow(HSI_F);title('HSI Image Sharppen Difference');
figure; imshow(Img_HSI_S);title('HSI Image Sharppen');
