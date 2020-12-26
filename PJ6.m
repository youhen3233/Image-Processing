%% Otsu Part
% Clear all command window, temporary variables and close all MATLAB  window 
clear; close all; clc; 
% Read the image, data type: uint8 [0, 255] 
Img = imread('fruit on tree.tif');
[M,N,Z] = size(Img);
%-----------------------------------------------------------------------------
R = Img(:,:,1); 
G = Img(:,:,2);
B = Img(:,:,3);
%figure; imshow(R);title('Original Image in R component'); 
[counts,x]=imhist(R);counts = counts / M / N; 
%figure; stem(x,counts);title('Normalized histogram of R component'); 
%-----------------------------------------------------------------------
%Cumulative sums P1---------------------------------------
temp = 0;
P1 = zeros(256,1);
for i = 1:256
    temp = 0;
    for j = 1:i
        temp = temp + counts(j);
    end
    P1(i) = temp;
end
%-----------------------------------------------------------------------
%Cumulative means m(k)---------------------------------------
m_k = zeros(256,1);
for i = 1:256
    temp = 0;
    for j = 1:i
        temp = temp + (j-2) * counts(j);
    end
    m_k(i) = temp;
end
%-----------------------------------------------------------------------
%Global mean m_g---------------------------------------
m_g = 0;
temp = 0;
for i = 1:256
    temp = temp + (i-1) * counts(i);
end
m_g = temp;
%-----------------------------------------------------------------------
%B_C_Var---------------------------------------
B_C_Var = zeros(256,1);
for i = 1:256
    B_C_Var(i) = (m_g * P1(i) - m_k(i))^2   /  ( P1(i) * (1 - P1(i)) ) ;
end
TP_B_C_Var = B_C_Var.';
[A , threshold] = max(TP_B_C_Var(1:255)) ; 
figure; stem(x,B_C_Var);title('Between-Class-Variance');
T = threshold / 255;
%-----------------------------------------------------------------------
%OTSU_Img---------------------------------------
OTSU_Img = Img;
Img2 = imbinarize(uint8(R) , T);
for i = 1:M
    for j = 1 : N
        if Img2(i,j) == 0
            OTSU_Img(i,j,1) = 128;
            OTSU_Img(i,j,2) = 128;
            OTSU_Img(i,j,3) = 128;
        end
    end
end
figure; imshow(OTSU_Img);title('OTSU output'); 
%% K-Means Part
%-----------------------------------------------------------------------
%K-means
Img_f = double(Img);
% Sorting
T = 10;    %The Tunable threshold T
mean1 =[75,75,75];
mean2 =[130,130,130];

sum1 = [0,0,0];
sum2 = [0,0,0];
cnt1 = 0;
cnt2 = 0;
Ena = 1;
while Ena == 1
    for i = 1:M
        for j = 1:N
            dist1 = sum((Img_f(i,j)-mean1).^2);
            dist2 = sum((Img_f(i,j)-mean2).^2);
            if dist1 < dist2 
                sum1 = sum1+Img_f(i,j);
                cnt1 = cnt1+1;
            else 
                sum2 = sum2+Img_f(i,j);
                cnt2 = cnt2+1;
            end
        end
    end
    N_m1 = sum1/cnt1;
    N_m2 = sum2/cnt2;
    
    E = sum(abs(N_m1-mean1)+abs(N_m2-mean2));
    E
    if E <= T
        Ena = 0;
    else
        mean1 = N_m1;
        mean2 = N_m2;
    end
end
%-----------------------------------------------------------------------
%K-means output
Img_K_output =  Img; 
%Cal the binarize
for i = 1:M
    for j = 1:N
            dist1 = sum((Img_f(i,j)-mean1).^2);
            dist2 = sum((Img_f(i,j)-mean2).^2);
            if dist1 < dist2 
                Img_K_output(i,j,1) = 128; 
                Img_K_output(i,j,2) = 128;
                Img_K_output(i,j,3) = 128;
            end
        end
end
figure(); imshow(Img_K_output); title("image color slicing");
