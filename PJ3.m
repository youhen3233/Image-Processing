img = imread('Bird 2 degraded.tif'); 
imgd = double(img)/255;
[m,n] = size(img); 
% Get Fourier transform of input image
X = fft2(imgd);
% Shift zero-frequency component to center of spectrum
X = fftshift(X); 
%------------------------------------------------------
%Origin image
figure(1);          
imshow(uint8(img));                
title('Bird2');
%----------------------------------------------------------------------------- 
% assignment1 
%Show the log Fourier magnitude spectra of the degraded image and normalize
figure(2);          
imshow(log(abs(X)+1)./log(max(abs(X(:))+1)));   
colormap(gray);
title('Fourier magnitude of the degraded image');
%----------------------------------------------------------------------------- 
%assignment2
%Show the log Fourier magnitude spectra of the degradation model
H = zeros(m,n);
k = 0.0005;    %constant
for u = 1:m
	for v = 1:n
			H(u,v) =  exp( (-k) *( ( (u-m/2)^2+(v-n/2)^2))^(5/6)   );
	end
end
figure(3);          
imshow(log(abs(H)+1)./log(max(abs(H(:))+1)));   
colormap(gray);
title('Fourier magnitude of the degradation model');
%----------------------------------------------------------------------------- 
%Butterworth LPF
B = zeros(m,n); 
LPF_n = 10;
image_r = 120;
for u = 1:m
    for v = 1:n
     B(u,v) =  1/sqrt((1+ (( sqrt((u-m/2)^2+  (v-n/2)^2))/image_r)^(2*LPF_n)));         
    end
end
%----------------------------------------------------------------------------- 
Hi = zeros(m,n); 
for u = 1:m
    for v = 1:n
        if sqrt((u-m/2)^2+(v-n/2)^2) <= image_r      
            Hi(u,v) = 1/(H(u,v))/B(u,v);
        else
            Hi(u,v) = 1;
        end
    end
end
%----------------------------------------------------------------------------- 
%assignment3
%output image
X_F = X.*Hi;
output = uint8(255*mat2gray(abs(ifft2(ifftshift(X_F)))));
figure(4);          
imshow(output);   
colormap(gray);
title('restored image, r = 50');
%title('restored image, r = 85');
%title('restored image, r = 120');
