clc;
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%------------VIDEO-------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%

main_v = VideoReader('t2.mov');

%%%%%%%%%%%%%%-----------------------------------------%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%---------Finding Total Frame In The Video----%%%%%%%%%%%

%reading the frame rate
frame_rate = main_v.FrameRate;

%processing the video upto last frame to generate number of frame
lastframe = read(main_v,inf); 

%finding to total frame
frame = main_v.NumberofFrames;

%taking background as first frame
background = read(main_v,1);
imshow(background);
title('Refrence Image');

%%%%%%%%%%%%%%%%%-----------------------------------------%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%---EDGE DETECTION OF TARGET IN THE VIDEO---%%%%%%%%%%%%%%%%%%

[oneRing,c,r,x_ring,y_ring,background] = find_target(background);

%%%%%%%%%%%%%%%%%%%%----------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%------for fun--------------%%%%%%%%%%%%%%%%%%%%%%%%%%

for video = 1:100:500
    figure;
    v1 = read(main_v,video);
   
    v1 = imresize(v1,[380,640]);
    v1 = imcrop(v1,[x_ring,y_ring,2*oneRing,2*oneRing+4]);

    v_gray = rgb2gray(v1);
    
    %only keeping the reb compenent;
    v_red_comp = v1(:,:,1);
    imshow(v_red_comp);
    title(['Finding the red laser',num2str(video)]);
    figure;
    %subtracing target to get required positon of the laser
    v_sub = imsubtract(v_red_comp,v_gray);
    imshow(v_sub);
    title(['Getting the exact position of laser',num2str(video)]);
    figure;
    %Chosing the threshold for the binary image;
    level = graythresh(v_sub);
    v_bin = imbinarize(v_sub,level);
    
    %finding the corrdinate of the laser
    [centers,radii] = imfindcircles(v_bin,[3,18]);
    imshow(v1);
    title(['Track of laser ',num2str(video)]);
    hold on;
    viscircles(centers,radii,'lineWidth',0.05,'Color','y');
    
    
end

%%%%%%%%%%%%%---------------------------------------%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%---------Tracing Laser position-------%%%%%%%%%%%%%%%%%%%%

%intializing variable to store center of the laser
tracer = zeros(frame,2);
temp_x = 1;

for video = 1:frame
    
    v1 = read(main_v,video);
   
    v1 = imresize(v1,[380,640]);
    v1 = imcrop(v1,[x_ring,y_ring,2*oneRing,2*oneRing+4]);

    v_gray = rgb2gray(v1);
    
    %only keeping the reb compenent;
    v_red_comp = v1(:,:,1);
    
    %subtracing target to get required positon of the laser
    v_sub = imsubtract(v_red_comp,v_gray);
    
    %Chosing the threshold for the binary image;
    level = graythresh(v_sub);
    v_bin = imbinarize(v_sub,level);
    
    %finding the corrdinate of the laser
    [centers,radii] = imfindcircles(v_bin,[3,18]);
    
    %intalizing the x and y corrdinate of the center of the laser 
    c_centers = isempty(centers);
    
    if (c_centers == 0) 
        tracer(temp_x,1) = centers(1,1);
        tracer(temp_x,2) = centers(1,2);
    end
    
    temp_x = temp_x+1;
    
end

%%%%%%-------Free up space----------%%%%%%%%%%%%%%%%%%

delete = {'temp_x','v1','centers','radii','v_bin','v_gray','v_sub','v_red_comp'};
clear (delete{:});


%%%%%%%%%%%%%%%%%-----------------------------------------%%%%%%%%%%%%%%%
%%%%%%%%%%%------Cordinate of the laser----------%%%%%%%%%%%%%%%%%

x_laser = tracer(:,1);
y_laser = tracer(:,2);

%%%%%%%%%%%%%%%%%-----------------------------------------%%%%%%%%%%%%%%%
%%%%%%%%--------Plot of the movement of the laser----------%%%%%%%%%

colour_draw(x_laser,y_laser,background);

   

%%%%%%%%%%%---------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%----------Making Of Taget and its processing--------------%%%%%%%%%%%%%%%%%
shot_cor = zeros(5,1);
aim_point = 0;
target(frame_rate,main_v.Duration,x_laser,y_laser,r,c,shot_cor,aim_point);





