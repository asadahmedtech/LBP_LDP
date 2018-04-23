function feature = LBPFeatureExtract(img)
    lbpimg = LBPImg(img);
    feature = zeros(256,1);
    lbpimg = lbpimg(:);
    for i = 1:size(lbpimg,1)
        feature(lbpimg(i)+1,1) = feature(lbpimg(i)+1,1) + 1;
    end
end

function lbpimg = LBPImg(img)
    [m,n] = size(img);
    lbpimg = zeros(m,n);
    z = zeros(8,1);
    for i=2:m-1
        for j=2:n-1        
            t=1;
            for k=-1:1
                for l=-1:1                
                    if (k~=0)||(l~=0)
                    if (img(i+k,j+l)-img(i,j)<0)
                        z(t)=0;
                    else
                        z(t)=1;
                    end
                    t=t+1;
                    end
                end
            end

            for t=0:7
               lbpimg(i,j)=lbpimg(i,j)+((2^t)*z(t+1));
            end
        end
    end
    lbpimg = uint8(lbpimg);
end
