function [oneRing,c,r,x,y,background] = find_target(background)


background = imresize(background,[380,640]);

%Converting  background to gray scale image
background_gray = rgb2gray(background);
imshow(background_gray);
title('Resized Gray Scale 380*640');
figure;
%Converting gray scale background to binary image
back_bini= imbinarize(background_gray,0.15);
imshow(back_bini);
title('Binary Image to detect Circle');
hold on;
%finding center and radius of black circular part in the background image
[c_b, r_b] = imfindcircles(back_bini,[43,58],'ObjectPolarity','dark');
viscircles(c_b,r_b,'lineWidth',0.05,'Color','r');
figure;
%%%%%%%%%-------Finding the target in the background------%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%---------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%pixel per MM 
pixelPerMM = r_b/59.5;
%distance of one from the center of the taret
oneRing = pixelPerMM*155.5;

%assuming cordinate of starting point of the rings 
 x = c_b(1)-oneRing;
 y = c_b(2)-oneRing;
 
 %%finding only the rquired area in the target i.e the ring part of the target
 background = imcrop(background,[x,y,2*oneRing,2*oneRing+4]);
 imshow(background);
 title('Extracting the target image form reference image');
 figure;
 %%%%%%%%%%%------------Finding the center of the new target -----------%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%---------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
 background_gray = imcrop(background_gray,[x,y,2*oneRing,2*oneRing+4]);
 background_bin = imbinarize(background_gray,0.15);
 [c, r] = imfindcircles(background_bin,[43,58],'ObjectPolarity','dark');
 imshow(background_bin);
 title('Detecting center form the target');
 hold on;
 viscircles(c,r,'lineWidth',0.05,'Color','r');
 %%%%%%%%%%%------free up space-------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 delete = {'background_gray','back_bini','background_bin','c_b','r_b','pixelPerMM'};
 clear (delete{:});
 
end