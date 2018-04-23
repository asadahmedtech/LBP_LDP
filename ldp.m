function histFeature = ldp(img,subregionX,subregionY,bins)
    load trees
    img = im2double(img);
%     img = rgb2gray(img);
%     img = imresize(img,[88 88]);
    [m,n]=size(img);
    width = floor(m/subregionX);
    height = floor(n/subregionY);
    histFeature = zeros(bins,subregionX*subregionY);
    k = 1;
    for i = 0:subregionY-1
        for j = 0:subregionX-1
            queryImage = imcrop(img, map, [((j)*width) ((i)*height) width height]);
            histFeature(:,k)= histCounts((LDPFeatureExtract(queryImage)),bins);      
            k = k + 1;
        end
    end
    histFeature = histFeature'; 
    histFeature = histFeature(:);
    end
function I = derivative(img, refX, refY, alpha)
    if alpha == 0
        I = img(refY, refX) - img(refY, refX+1);
    elseif alpha == 45
        I = img(refY, refX) - img(refY-1, refX+1);
    elseif alpha == 90
        I = img(refY, refX) - img(refY-1, refX);
    elseif alpha == 135
        I = img(refY, refX) - img(refY-1, refX-1);
    end
end

function F = comparison(I1, I2)
    if I1*I2 > 0
        F = 0;
    else
        F = 1;
    end
end

function binary = LDPAlpha(img, refX, refY, alpha)
    binary = zeros(8,1);
    binary(1) = comparison(derivative(img,refX,refY,alpha),derivative(img,refX-1,refY-1,alpha));
    binary(2) = comparison(derivative(img,refX,refY,alpha),derivative(img,refX,refY-1,alpha));
    binary(3) = comparison(derivative(img,refX,refY,alpha),derivative(img,refX+1,refY-1,alpha));
    binary(4) = comparison(derivative(img,refX,refY,alpha),derivative(img,refX+1,refY,alpha));
    binary(5) = comparison(derivative(img,refX,refY,alpha),derivative(img,refX+1,refY+1,alpha));
    binary(6) = comparison(derivative(img,refX,refY,alpha),derivative(img,refX,refY+1,alpha));
    binary(7) = comparison(derivative(img,refX,refY,alpha),derivative(img,refX-1,refY+1,alpha));
    binary(8) = comparison(derivative(img,refX,refY,alpha),derivative(img,refX-1,refY,alpha));
end

function a = LDP(img, refX, refY, alpha)
    ldp = zeros(8,1);
    a = 0;
    ldp(1:8) = LDPAlpha(img, refX, refY, alpha);
%     ldp(9:16) = LDPAlpha(img, refX, refY, 45);
%     ldp(17:24) = LDPAlpha(img, refX, refY, 90);
%     ldp(25:32) = LDPAlpha(img, refX, refY, 135);
    %for i=0:3
    i=0;
    for t=0:7
    a = a + ((2^(t))*ldp((8-t)+(i*8))); %decimal to binary conversion
    end
    %end

end

function hldp = HLDP(img)
    feature = zeros(256,1);
    img = img(:);
    for i = 1:size(img,1)
        feature(img(i)+1,1) = feature(img(i)+1,1) + 1;
    end
    hldp = feature;
end
function ldpimg = LDPImg(img,alpha)
    [m,n] = size(img);
    ldpimg = zeros(m,n);
    for i=3:m-2
        for j=3:n-2
            ldpimg(i,j) = LDP(img,j,i,alpha);
        end
    end
    ldpimg = uint8(ldpimg);
end

function feature = LDPFeatureExtract(img)
    feature = zeros(256*4,1);
    ldpimg1 = LDPImg(img,0);
    ldpimg2 = LDPImg(img,45);
    ldpimg3 = LDPImg(img,90);
    ldpimg4 = LDPImg(img,135);
    
    feature1 = HLDP(ldpimg1);
    feature2 = HLDP(ldpimg2);
    feature3 = HLDP(ldpimg3);
    feature4 = HLDP(ldpimg4);
    
    feature(1:256) = feature1;
    feature(257:512) = feature2;
    feature(513:768) = feature3;
    feature(769:1024) = feature4;
end

function hist = histCounts(histogram, bins)
    hist = zeros(bins,1);
    width = size(histogram,1)/bins;
    for i = 0:bins-1
        for j = (width*i)+1:(width*(i+1))
            hist(i+1,1)=hist(i+1,1)+histogram(j,1);
        end
    end
end


