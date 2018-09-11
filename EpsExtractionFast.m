%%Permittivity extraction from Near-field S3 real and imaginary images







 %%mode number represents which model to use for permittivity extration. Mode 1 uses Tat's model. Mode 2 uses Alex's model; Mode 3 uses
% point-dipole model
mode = 1;
%load experimental images
reals=load('S3_real.txt');
imgs=load('S3_imag.txt');

experimental = reals + (1i*imgs);
surf(reals);
shading interp
view(0,90)
%Extraction with point-dipole model
if(mode == 3)
load('pointdipolelibrary.mat')
constants=S3'*1e22;
eps1p=e_1;
eps2p=e_2;
end
if mode==1
load('refinedlibrary.mat')

constants=real(S3p)-1i*imag(S3p);
end

%Reference point permittivity
eps_ref=-100+100*1i;
%Reference point pixel positiom
x_ref=117;
y_ref=55;



[~, x]=min(abs(eps1p-real(eps_ref)));
[~, y]=min(abs(eps2p-imag(eps_ref)));
constants_ref=constants(y,x);

%normalized images to library scale
experimental=experimental.*constants_ref/experimental(y_ref,x_ref);




originalConstants = constants;
originalExp = experimental;

experimental = experimental(:);
constants = constants(:);


%the index of a value in constants will correspond to an index in the
%in the original matrix, That index can be converted to a subscript with
%ind2sub()
[constants, IC] = sort(constants, 'descend');


for i = 1:size(experimental)
    %find index of nearest point to experimental point
    [~, index] = nearestPoint(experimental(i), constants);

    %find index of esp based on original version of array
    index = IC(index);

    %get the subscript of index from the index value,
    [x1, y1]=ind2sub(size(originalConstants),index);
    %indexExp = IE(i);
    indexExp = i;
    [constIndex_j,constIndex_i] = ind2sub(size(originalExp), indexExp);
    eps(constIndex_j,constIndex_i)=eps1p(y1)+1i*eps2p(x1);
    disp(i);
end
%plot resutls
figure(1)
imagesc(real(eps))
figure(2)
imagesc(imag(eps))


function index = nearestMagnitude(constants, value)
          if(abs(constants(2)) < abs(value))
          index = 1;
          return
          end
          if(abs(constants(size(constants,1))) > abs(value))
          index = size(constants,1);
          return
          end

          lo = 2;
          hi = size(constants, 1);

          while (lo < hi)
            mid = floor((hi + lo) / 2);

            if (abs(value) > abs(constants(mid)))
                hi = mid - 1;
            end
            if(abs(value) < abs(constants(mid)))
                lo = mid + 1;
            end
            if(abs(value) == abs(constants(mid)))
                index = mid;
                return
             end
           end


          if(abs(constants(lo)) - abs(value) > abs(constants(hi)) - abs(value))
          if(lo == 1)
              index = 2;
              return
          end
          index = lo;
          return
          end
          if(hi == 1)
              index = 2;
              return;
          end
          index = hi;

          return
end
function [np, index] = nearestPoint(centerPoint, constants)
nm = nearestMagnitude(constants, centerPoint);
[np, index] = nearestPointHelper(.00005, centerPoint, constants, nm, nm+1);

end
function [np, index] = nearestPointHelper(radius,centerPoint, constants, left_index, right_index)

 currentIndex = -1;
 %add left to circle
 while(left_index  > 0 & (abs(centerPoint) + radius) > (abs(constants(left_index))) )
        distance = centerPoint - constants(left_index);
        if(distance <= radius)
               if(currentIndex ~= -1)
           % currentIndexDist = abs(constants(currentIndex) - centerPoint);
               end
            if(currentIndex == -1 || currentIndexDist < distance)
                currentIndex = left_index;
                currentIndexDist = distance;

            end
        end
        left_index = left_index-1;

 end

%add right to circle
 while(right_index < size(constants) & abs(centerPoint) - radius) > (abs(constants(right_index)))

       distance = centerPoint - constants(right_index);
       if(distance <= radius)
            if(currentIndex ~= -1)
            end
            if(currentIndex == -1 || currentIndexDist < distance)
                currentIndex = right_index;
                currentIndexDist = distance;

            end
       end
        disp(right_index);
        right_index = right_index+1;
 end
    if(currentIndex ~= -1)
    index = currentIndex;
    np = constants(currentIndex);

    return
    end
    [np, index] = nearestPointHelper(radius*2 , centerPoint, constants, left_index, right_index);



end
