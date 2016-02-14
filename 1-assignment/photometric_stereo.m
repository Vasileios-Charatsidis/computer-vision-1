function photometric_stereo( )
%PHOTOMETRIC_STEREO Summary of this function goes here
%   Detailed explanation goes here

sp1 = imread('sphere1.png');
sp2 = imread('sphere2.png');
sp3 = imread('sphere3.png');
sp4 = imread('sphere4.png');
sp5 = imread('sphere5.png');

n_sources = 5;
nrows = size(sp1, 1);
ncols = size(sp1, 2);

sources = zeros(nrows, ncols, n_sources);
sources(:, :, 1) = sp1(:,:);
sources(:, :, 2) = sp2(:,:);
sources(:, :, 3) = sp3(:,:);
sources(:, :, 4) = sp4(:,:);
sources(:, :, 5) = sp5(:,:);

light_distance = 2200;
light_frontal_height = 1700;
light_height = 165;

% center
v1 = [ nrows / 2; ncols / 2; light_frontal_height ];
% bottom-right
v2 = [ nrows + light_distance; ncols + light_distance; light_height ];
% bottom-left
v3 = [ nrows + light_distance; -light_distance; light_height ];
% top-right
v4 = [ -light_distance; ncols + light_distance; light_height ];
% top-left
v5 = [ -light_distance; -light_distance; light_height ];  

V = [v1'; v2'; v3'; v4'; v5'];

normals = zeros(nrows, ncols, 3);
albedos = zeros(nrows, ncols);
for x=1:size(sp1, 1);
    for y=1:size(sp1, 2);
        % stack image values into array i
        i = zeros(n_sources, 1);
        for k=1:n_sources;
            i(k) = sources(x, y, k);
        end
        % construct diagonal matrix I
        I = zeros(n_sources, n_sources);
        for k=1:n_sources;
            I(k, k) = i(k);
        end
        % solve for g
        A = I * V;
        b = I * i;
        g = pinv(A) * b;
        
        albedos(x, y) = norm(g);
        if albedos(x, y) == 0;
            normals(x, y, :) = [0 0 0];
        else
            normals(x, y, :) = g / albedos(x, y);
        end
    end
end

% if the albedo is not in the range [0, 1], then V might be incorrect
if max(max(albedos)) > 1 || min(min(albedos)) < 0
    error('Albedo values not in [0, 1]');
end

% show recovered albedo
figure
imshow(albedos, [])
title('Recovered albedo')

% show normal map
figure
Un = normals(:, :, 1);
Vn = normals(:, :, 2);
Wn = normals(:, :, 3);

% mask = albedos > 0.05;
% ar = reshape(albedos(mask), [nrows ncols]);
% ur = reshape(Un(mask), [nrows ncols]);
% vr = reshape(Vn(mask), [nrows ncols]);
% wr = reshape(Wn(mask), [nrows ncols]);
% quiver3(ar, ur, vr, wr, 'AutoScale', 'off', 'AutoScaleFactor', 10)

quiver3(albedos, Un, Vn, Wn, 'AutoScale', 'off', 'AutoScaleFactor', 10)

view(-35,45)
title('Normal map image')


% reconstruct height map
height_map = zeros(nrows, ncols);
for y=2:nrows;
    q = Vn(y, 1) / Wn(y, 1);
    if isnan(q);
        q = 0;
    end
    height_map(y, 1) = height_map(y-1, 1) + q;
end
for y=1:nrows;
    for x=2:ncols;
        p = Un(y, x) / Wn(y, x);
        if isnan(p);
            p = 0;
        end
        height_map(y, x) = height_map(y, x-1) + p;
    end
end

figure
surfl(height_map); shading interp; colormap gray

end
