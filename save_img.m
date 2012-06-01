function save_img(segmented_img,lambda, im_name)
    %[l,s] = size(segmented_img);
    iter = size(segmented_img);
    for i = 1:iter(1)
        for j = 1:iter(2)
            imwrite(segmented_img{i,j}, sprintf('%s_%f_%d.jpg',im_name,lambda(i),j), 'jpeg');
        end
    end
end
