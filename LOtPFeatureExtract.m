function feature = LOtPFeatureExtract()
%     img = im2double(img);
%     img = rgb2gray(img);
%     img = imresize(img,[256 384]);
%     [m,n]=size(img);
    img = [7, 5, 9, 7, 4; 8,5,4,5,2; 5,3,8,6,5; 2,4,2,5,6; 4,3,0,1,2;];
    feature = vectorformation(img, 3, 3);
    hist(feature);
end

function I = derivative(img, refX, refY, alpha)
    if alpha == 0
        I = -img(refY, refX) + img(refY, refX+1);
    elseif alpha == 45
        I = -img(refY, refX) + img(refY-1, refX+1);
    elseif alpha == 90
        I = -img(refY, refX) + img(refY-1, refX);
    end
end

function Idir = direction(img ,refX, refY)
    
    a = derivative(img, refX, refY, 0);
    b = derivative(img, refX, refY, 45);
    c = derivative(img, refX, refY, 90);
    
    if a >= 0 && b >= 0 && c >= 0
        Idir = 1;
    elseif a >= 0 && b >= 0 && c < 0
        Idir = 2;
    elseif a >= 0 && b < 0 && c >= 0
        Idir = 3;
    elseif a >= 0 && b < 0 && c < 0
        Idir = 4;
    elseif a < 0 && b >= 0 && c >= 0
        Idir = 5;
    elseif a < 0 && b >= 0 && c < 0
        Idir = 6;
    elseif a < 0 && b < 0 && c >= 0
        Idir = 7;
    elseif a < 0 && b < 0 && c < 0
        Idir = 8;
    end 
end

function F = comparison(I1, I2)
    if I1 == I2
        F = 0;
    else
        F = I2;
    end
end

function pattern = octalpattern(img, refX, refY)
    pattern = zeros(8,1);
    pattern(1) = comparison(direction(img,refX,refY),direction(img,refX-1,refY-1));
    pattern(2) = comparison(direction(img,refX,refY),direction(img,refX,refY-1));
    pattern(3) = comparison(direction(img,refX,refY),direction(img,refX+1,refY-1));
    pattern(4) = comparison(direction(img,refX,refY),direction(img,refX+1,refY));
    pattern(5) = comparison(direction(img,refX,refY),direction(img,refX+1,refY+1));
    pattern(6) = comparison(direction(img,refX,refY),direction(img,refX,refY+1));
    pattern(7) = comparison(direction(img,refX,refY),direction(img,refX-1,refY+1));
    pattern(8) = comparison(direction(img,refX,refY),direction(img,refX-1,refY));
end

function value = tobinaryconversion(pattern, direction)
    value = 0;
    for i = 1:8
        if pattern(i) == direction
            value = value + 1*(2^(8-i));
        end
    end
end

function m = magnitude(img, refX, refY)
    a = derivative(img, refX, refY, 0);
    b = derivative(img, refX, refY, 45);
    c = derivative(img, refX, refY, 90);
    m = sqrt(a*a + b*b + c*c);
end

function m = magnitudeofvec(img, refX, refY)
    m = 0;
    mag = zeros(8,1);
    mag(1) = magnitude(img,refX-1,refY-1);
    mag(2) = magnitude(img,refX,refY-1);
    mag(3) = magnitude(img,refX+1,refY-1);
    mag(4) = magnitude(img,refX+1,refY);
    mag(5) = magnitude(img,refX+1,refY+1);
    mag(6) = magnitude(img,refX,refY+1);
    mag(7) = magnitude(img,refX-1,refY+1);
    mag(8) = magnitude(img,refX-1,refY);
    mag = mag - magnitude(img, refX, refY);
    
    for i = 1:8
        if mag(i)>=0
            m = m + (2^(8-i))*1;
        end
    end
end

function vec = vectorformation(img, refX, refY)
    vec = zeros(57,1);
    idx = 1;
    origcenter = img(refY,refX);
    for centerdirection = 1:8
        img(refY,refX) = centerdirection;
        pattern = octalpattern(img, refX, refY);
        for direction = 1:8
            if direction~=centerdirection
                vec(idx) = tobinaryconversion(pattern, direction);
                idx = idx + 1;
            end
        end
    end
    img(refY,refX) = origcenter ;
    vec(idx) = magnitudeofvec(img, refX, refY);
end