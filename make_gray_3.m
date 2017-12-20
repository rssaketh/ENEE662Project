path1 = 'example_images/spongebob/gray';
path2 = 'example_images/spongebob/gray1';
mkdir(path2);
files = dir(strcat(path1,'/output-*'));
for i = 1 : numel(files)
    a = imread(fullfile(path1,files(i).name));
    b = cat(3,a,a,a);
    imwrite(b, strcat(path2,sprintf('/output-%d.jpg',i-1))); % img%04d.jpg
end