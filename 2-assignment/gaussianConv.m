function im_out2 = gaussianConv( im_path, sigma_x, sigma_y )
%GAUSSIANCONV Convolute an image with a 2D Gaussian filter

kernel_length = 11;

% Load image
im = im2double(imread(im_path));
size_c = size(im, 3);

% Create 1-dimensional kernels
kernel_x = gaussian(sigma_x, kernel_length)';
kernel_y = gaussian(sigma_y, kernel_length);
% Create 2-dimensional kernel
kernel = kernel_x * kernel_y;


% Apply 2D kernel to image
for i=1:size_c;
    im_out2(:,:,i) = conv2(im(:,:,i), kernel, 'same');
end
% Apply 1D kernels to image, first columns and then rows
for i=1:size_c;
    im_out1(:,:,i) = conv2(kernel_x, kernel_y, im(:,:,i), 'same');
end
[size_y, size_x, size_c] = size(im_out1);


% Assert that the results of 1D convolution is the same as 2D one
% (within a small epsilon value)
eps = 1e-12;
error = zeros(size_y, size_x, size_c);
for y=1:size_y;
    for x=1:size_x;
        p1 = im_out1(y, x);
        p2 = im_out2(y, x);
        error(y,x) = abs(p1 - p2);
        assert(p1 > p2 - eps && p1 < p2 + eps, '1D convolution results are not the same as 2D one!')
    end
end


% Produce heat map to visualize error per pixel
addedError = mean(error, 3);
hmo = HeatMap(addedError)

% Show original image
figure
imshow(im, []);
title('Original')
sx_str = num2str(sigma_x); sy_str = num2str(sigma_y);
% Show image filtered with 2D kernel
figure
imshow(im_out2, []);
title(['2D filtered _{\sigma_x=', sx_str, ', \sigma_y=', sy_str, '}']);
% Show image filtered with 1D kernels
figure
imshow(im_out1, []);
title(['1D filtered _{\sigma_x=', sx_str, ', \sigma_y=', sy_str, '}']);

equiv = mean(mean(addedError));

end

