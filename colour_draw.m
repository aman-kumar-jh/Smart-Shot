function colour_draw(x_laser,y_laser,background)

%%%%%%%%--------Colour intialization for input image-----------------%%%%%%%%%%%%%%%


%slope = y_laser(:)./x_laser(:);
red_cor = round(length(x_laser)*0.125);
yel_cor = round(length(x_laser)*0.425);
green_cor = round(length(x_laser)*0.765);
blue_cor = length(x_laser) - green_cor;
%intalizing of the red colour the first few pixel
x_red = x_laser(1:red_cor);
y_red = y_laser(1:red_cor);

%intalizing of the yellow colour to next few pixel
x_yellow = x_laser(red_cor:yel_cor);
y_yellow = y_laser(red_cor:yel_cor);

%intalizing of the green colour to next few pixel
x_green = x_laser(yel_cor:green_cor);
y_green = y_laser(yel_cor:green_cor);

%intalizing of the blue colour to next few pixel
x_blue = x_laser(green_cor:blue_cor);
y_blue = y_laser(green_cor:blue_cor);

%%%%%%-------ploting the tracked laser with defined colour on background-------%%%%%%%
%%%%%%%%%%%%%%----------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
imshow(background);
title('Movement of laser');
hold on;

%%%%%%-----plot of the line---------%%%%%%%%%%%%%%%%%%%%
line(x_red,y_red,'Color','r');
hold on;
line(x_yellow,y_yellow,'Color','yellow');
hold on;
line(x_green,y_green,'Color','g');
hold on;
line(x_blue,y_blue,'Color','b');

delete = {'x_red','y_red','x_yellow','y_yellow','x_green','y_green','x_blue','y_blue'};
clear (delete{:});

end