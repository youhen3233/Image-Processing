
img = imread('Bird 2.tif'); 
%-----------------------------------------------------------------------------
[m,n] = size(img); 
%Plot
figure(1);          imshow(uint8(img));                title('Bird2');
%-----------------------------------------------------------------------------
% Padded Image
padded = zeros(m*2,n*2); 
padded(1:m, 1:n)=img(1:m,1:n);
%Plot
figure(2);          imshow(uint8(padded));      title('Padded image') ;
%-----------------------------------------------------------------------------
% Multuply padded image by (-1)^(x+y)
for W = 1: 2*m
    for D = 1: 2*n
        padded(W,D) = padded(W,D) * (-1)^(W-1+D-1);
    end
end
% Plot 
%figure(3);          imshow(uint8(padded));         title('(-1)^(x+y) image') ;
%-----------------------------------------------------------------------------
% Do the fft on Padded image
FT = fft2(padded);
Spectrum = log(abs(FT));
figure(4);          imagesc(uint8(Spectrum));      title('Log scaled FFT image');  
%-----------------------------------------------------------------------------
% gaussian low pass filter after FFT
LP = zeros(m*2,n*2); 
WG = m;
DG = n;
for W  = 1:2*m
    for D = 1:2*n
        if  sqrt((W-WG)^2+(D-DG)^2)<60
            LP(W,D) = 1;
        end
    end
end
%figure(5);         imshow(uint8(LP));           title('lowpass') ;
%-----------------------------------------------------------------------------
% gaussian High pass filter after FFT 
HP = zeros(m*2,n*2); 
WG = m;
DG = n;
for W  = 1:2*m
    for D = 1:2*n
        if  sqrt((W-WG)^2+(D-DG)^2)>=60   %outside circular region
            HP(W,D) = 1;
        end
    end
end
%-----------------------------------------------------------------------------
% Inside the region choose LP. outside choose HP
%S2 = LP.*FT;
S2 = HP.*FT; 
figure(6);          imshow(S2);                 
%title('lowpass*F') ;
title('highpass*F') ;
%-----------------------------------------------------------------------------
% inverse
out = ifft2(S2); 
%figure(7);          imshow(uint8(out));         title('ifft2') ;
%-----------------------------------------------------------------------------
% Take realpart and do (-1)^(x+y) multiplying to recover the image
out = real(out);
for W = 1:2*m
    for D = 1:2*n
        out(W,D) = out(W,D)*(-1)^(W-1+D-1);
    end
end
%figure(8), imshow(uint8(out)); title('ifft2 *(-1)^(r-1+c-1)') ;
%-----------------------------------------------------------------------------
% Crop the image as the origin image size
Crop = out(1:m,1:n);
%figure(9); imshow(uint8(out));title('Output image') ;
figure(10); imshow(uint8(Crop));title('Cropped') ;
%-----------------------------------------------------------------------------
                        %Image result  part over
%-----------------------------------------------------------------------------


%-----------------------------------------------------------------------------
% DFT table part
Vec = reshape(FT(1:m,1:n), [1], []);      %matrix2vector
SVec = sort(Vec,'ComparisonMethod','auto');  %sort vector
F_SVec = flip(SVec);
F_SVec = F_SVec(1:25);

index_u_v_value = zeros(25,3);
for i=1:m
    for j=1:n
        for k=1:25
            if F_SVec(k) == FT(i,j)
               index_u_v_value(k,1)=uint16(i-1);  %u
               index_u_v_value(k,2)=uint16(j-1);  %v
               index_u_v_value(k,3)=F_SVec(k);    %value
            end
        end
    end
end
F_SVec = reshape (F_SVec,[],[1]);
csvwrite('u_v_value_file.csv',index_u_v_value);
