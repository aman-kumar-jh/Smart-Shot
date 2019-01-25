clc;
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%------------VIDEO-------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%

 v = VideoReader('dual_l_Trim.mp4');
 
 %%%%%%%%%%%%%%-----------------------------------------%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%---------Finding Total Frame In The Video----%%%%%%%%%%%

%reading the frame rate
lastframe = read(v,inf);
  
%processing the video upto last frame to generate number of frame
frame_rate = v.FrameRate;

%finding to total frame  
frame = v.NumberofFrames;

%taking background as first frame
 background = read(v,1);
 
 %%%%%%%%%%%%%%%%%-----------------------------------------%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%---EDGE DETECTION OF TARGET IN THE VIDEO---%%%%%%%%%%%%%%%%%%

[oneRing,c,r,x_ring,y_ring,background] = find_target(background);


%%%%%%%%%%%%%%%%%%%%----------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%------for fun--------------%%%%%%%%%%%%%%%%%%%%%%%%%%

for video = 1:50:250
    
    figure;
    v1 = read(v,video);
   
   v1 = imresize(v1,[380,640]);
   v1 = imcrop(v1,[x_ring,y_ring,2*oneRing,2*oneRing+4]);
     
    v_gray = rgb2gray(v1);
    
    v_red_comp = v1(:,:,1);
    imshow(v_red_comp);
    title(['Finding the red laser',num2str(video)]);
    figure;
    
    v_sub = imsubtract(v_red_comp,v_gray);
    imshow(v_sub);
    title(['Getting the exact position of laser',num2str(video)]);
    figure;
    
    level = graythresh(v_sub);
    v_bin = imbinarize(v_sub,level);


    [centers,radii] = imfindcircles(v_bin,[2,10],'Sensitivity',0.9);
    imshow(v1);
    title(['Track of laser ',num2str(video)]);
    hold on;
    viscircles(centers,radii,'lineWidth',0.05,'Color','y');


end
    
    
 


%%%%%%%%%%%%%---------------------------------------%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%---------Tracing Laser position-------%%%%%%%%%%%%%%%%%%%%

tracer = zeros(frame,2);
temp_x = 1;
ff = zeros(int16(frame/10),1);
track_ff = 1;
sum=0;

 for video = 1:frame
    v1 = read(v,video);
   
   v1 = imresize(v1,[380,640]);
   v1 = imcrop(v1,[x_ring,y_ring,2*oneRing,2*oneRing+4]);
     
    v_gray = rgb2gray(v1);
    v_red_comp = v1(:,:,1);
    v_sub = imsubtract(v_red_comp,v_gray);
    
    level = graythresh(v_sub);
    v_bin = imbinarize(v_sub,level);


    [centers,radii,metric] = imfindcircles(v_bin,[2,10],'Sensitivity',0.9);
%     viscircles(centers,radii,'lineWidth',0.05,'Color','r');
%      figure;

     c_centers = isempty(centers);
     if(c_centers ==0)
        [mag,row] = min(centers(:,1));
        [m_c,n_c] = size(centers);
        if(m_c > 1 && sum == 0)
            ff(track_ff) = video;
            track_ff = track_ff + 1;
            sum = video;
        else
            sum = 0;
        end
        
        tracer(temp_x,1) = centers(row,1);
        tracer(temp_x,2) = centers(row,2);
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

shot_track = 0;
shot_cor = zeros(5,1);
s_x = 1;
for j =1:length(ff)
    if(ff(j)>shot_track)
        shot_cor(s_x) = ff(j);
        s_x = s_x + 1;
        shot_track = shot_track + std(ff);
    end
    
end



%%%%%%%%%%%---------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%----------Making Of Taget and its processing--------------%%%%%%%%%%%%%%%%%
aim_point = input('What is your aiming point in number range from [6,4]  ');
target(frame_rate,v.Duration,x_laser,y_laser,r,c,shot_cor,aim_point);

%%%%%%%%%%------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%-----Plot of pellet postion and cal of score----%%%%%%%%%%%%%%%

