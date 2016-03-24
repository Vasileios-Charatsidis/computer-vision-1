set_env, clear, close all

metadata.airplanes.impath = './Caltech4/ImageData/airplanes_%s/img%03d.jpg';
metadata.airplanes.train = 500;
metadata.airplanes.test = 50;
metadata.cars.impath = './Caltech4/ImageData/cars_%s/img%03d.jpg';
metadata.cars.train = 465;
metadata.cars.test = 50;
metadata.faces.impath = './Caltech4/ImageData/faces_%s/img%03d.jpg';
metadata.faces.train = 400;
metadata.faces.test = 50;
metadata.motorbikes.impath = './Caltech4/ImageData/motorbikes_%s/img%03d.jpg';
metadata.motorbikes.train = 500;
metadata.motorbikes.test = 50;

labels = fieldnames(metadata);


sift_type = 'RGB';
nim_visual_voc = 50;

all_features = cell(nim_visual_voc * length(labels), 1);
k = 1;
for i = 1:length(labels)
    label = labels{i};
    class_metadata = metadata.(label);
    if nim_visual_voc > class_metadata.train
        error('Not enough training images available!')
    end
    
    sample_idx = randperm(class_metadata.train, nim_visual_voc);
    for s = 1:numel(sample_idx)
        sample_id = sample_idx(s);
        impath = sprintf(class_metadata.impath, 'train', sample_id);
        fprintf('Label: %s\t%d\n', label, s);
        im = imread(impath);
        im = im2double(im);
        descriptors = sift_descriptors(im, sift_type);
        if size(descriptors, 2) == 3
            all_features{k} = [descriptors{1}', descriptors{2}', descriptors{3}'];
            k = k + 1;
        else
            fprintf('Image %s is grayscale\n', impath)
        end
    end
end
all_features = cell2mat(all_features);

% cluster all descriptors
K = 10;
tic
[idx, centers] = kmeans(double(all_features), K, 'OnlinePhase', 'off');
toc
