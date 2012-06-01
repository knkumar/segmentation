function [graph] = compute_unary(bgrnd, fgrnd, graph, source, sink , lambda, im_data) 
    %case 1
    p = pfb(im_data, fgrnd, bgrnd);
    graph(source,:) = [p+lambda 0 0];
    graph(source,source) = 0;
    graph(source,sink) = 0;
    %case 2
    graph(source,fgrnd) = inf;
    %case 3
    graph(:, sink) = 0;
    %case 4
    graph(bgrnd,sink) = inf;
end


function [p] = pfb(im_data, fg, bg)
    
    red = double(im_data(:,:,1));
    blue = double(im_data(:,:,2));
    green = double(im_data(:,:,3));
    img = [ red(:) blue(:) green(:)];
    
    fg_img = [red(fg(:)) blue(fg(:)) green(fg(:))];
    bg_img = [red(bg(:)) blue(bg(:)) green(bg(:))];
    % fg computation
    fg_mean = mean(fg_img);
    bg_mean = mean(bg_img);
    fg_cov = cov(fg_img);
    bg_cov = cov(bg_img);
    if any(fg_cov)
        fg_inv = inv(fg_cov);
    else
        fg_inv = fg_cov;
    end
    if any(bg_cov)
        bg_inv = inv(bg_cov);
    else
        bg_inv = bg_cov;
    end
    p = zeros(1,size(img,1));
    for i = 1:size(img,1)
        lnf = -(log(det(fg_cov))/2) - ((1/2)*(img(i,:) - fg_mean)*fg_inv*(img(i,:)-fg_mean)');
        lnb = -(log(det(bg_cov))/2) - ((1/2)*(img(i,:) - bg_mean)*bg_inv*(img(i,:)-bg_mean)');
        prob = lnf - lnb;
        p(i) = mean(prob(:));
    end
end
