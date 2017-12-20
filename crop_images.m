% resize the marked frames from 320x240 -> 240x320
for idx = 0 : 4
    path = 'example_images/toddler-markings/';
    img = sprintf('%soutput-%d.jpg', path, idx);
    init_img = imread(img);
    new_img = [zeros(size(init_img,1),40,size(init_img,3)),init_img,zeros(size(init_img,1),40,size(init_img,3))];
    new_crop_img = imresize3(new_img, [size(init_img,1),size(init_img,2),size(init_img,3)]);
    imwrite(new_crop_img,sprintf('%scrop-%d.jpg',path,idx));
end