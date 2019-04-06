function target(frame_rate,Duration,x_laser,y_laser,r,c,shot_cor,aim_point)

%taking the background image for the target

target = imread('white_back.jpeg');
imshow(target);
title('Reference image for creating digital target');
fig_target  = figure;

%defining center,radius,pixel/mm 
centersDark = c;
radiiDark = r;
pixelPerMM = r/59.5;

%assigning value to the rings
innerTenRing = pixelPerMM*5;
tenRing = pixelPerMM*11.5;
nineRing = pixelPerMM*27.5;
eightRing = pixelPerMM*43.5;
sevenRing = r;

diffBetween2rings = nineRing - tenRing;

sixRing = sevenRing + diffBetween2rings;
fiveRing = sixRing + diffBetween2rings;
fourRing = fiveRing + diffBetween2rings;
threeRing = fourRing + diffBetween2rings;
twoRing = threeRing + diffBetween2rings;
oneRing = twoRing + diffBetween2rings;

%resizing the target accoriding to origanl image
target = imresize(target,[234,234]);

%width of the ring
circleWidth = pixelPerMM*0.05;

%%%%%%%%-----_--------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%----amining point selection---%%%%%%%%%%%%%%%%%%%%%%%%%%
if(aim_point == 6)
    aim_point = sixRing;
elseif(aim_point == 5)
    aim_point = fiveRing;
elseif(aim_point == 4)
    aim_point = fourRing;
end
%%%%%%%%%%%------------------------------------%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%--------plot of the target --------%%%%%%%%%%%%%%%%%%%%%%%

imshow(target);
title('Digital target');
hold on;

%7th ring with filled black colour 
rectangle('Position',[c(1)-r c(2)-r 2*r 2*r],'Curvature',[1 1],'FaceColor','k')
hold on;

%one ring
viscircles(centersDark,oneRing,'lineWidth',circleWidth,'Color','k');
hold on;

%2nd ring
viscircles(centersDark,twoRing,'lineWidth',circleWidth,'Color','k');
hold on;

%3rd ring
viscircles(centersDark,threeRing,'lineWidth',circleWidth,'Color','k');
hold on;

%4th ring
viscircles(centersDark,fourRing,'lineWidth',circleWidth,'Color','k');
hold on;

%5th ring
viscircles(centersDark,fiveRing,'lineWidth',circleWidth,'Color','k');
hold on;

%6th ring
viscircles(centersDark,sixRing,'lineWidth',circleWidth,'Color','k');
hold on;

%8th ring
viscircles(centersDark,eightRing,'lineWidth',circleWidth,'Color','w');
hold on;

%9th ring
viscircles(centersDark,nineRing,'lineWidth',circleWidth,'Color','w');
hold on;

%10th ring
viscircles(centersDark,tenRing,'lineWidth',circleWidth,'Color','w');
hold on;

%10x ring
viscircles(centersDark,innerTenRing,'lineWidth',circleWidth,'Color','w');
hold on;

%%%%%%%%%%%%%%%-----------------------------------------%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%------------calculaion of accuracy,movment of gun--%%%%%%%

cancel_shot = 0;
time_green = 0;
time_yellow =0;
time_red = 0;
time_marron =0;

for e = 1:2:(length(x_laser)-1)
    %checking wheather laser is in white region expect in left and right of
    %black portion along x axis(according to matlab)
    %giving red to movement of laser
    if( (x_laser(e) <= (centersDark(2) - radiiDark)) || (x_laser(e) >(centersDark(2) + radiiDark)))
        plot([x_laser(e),x_laser(e+1)],[y_laser(e),y_laser(e+1)],'Color','r','LineWidth',0.75);
        time_red = time_red + 1;
        hold on;
    
    %checking wheather laser is in white region upper of black region and
    %lower after the four line region along y axis(according to matlab)
    %giving red to movement of laser
    elseif (y_laser(e) <= (centersDark(1) - radiiDark) || y_laser(e) > (centersDark(1) + fourRing))
            plot([x_laser(e),x_laser(e+1)],[y_laser(e),y_laser(e+1)],'Color','r','LineWidth',0.75);
            time_red = time_red + 1;
            hold on;
    
    %processing of the black region
    elseif (y_laser(e) <= (centersDark(1) + radiiDark))
        %checking if there is throw back of gun
        %giving maron colour to movement of laser
            if(cancel_shot == 1&& y_laser(e) <= centersDark(1))
                plot([x_laser(e),x_laser(e+1)],[y_laser(e),y_laser(e+1)],'Color','m','LineWidth',0.95);
                time_marron = time_marron + 1;
         %alert signal i.e changining color to yellow   
            else
                plot([x_laser(e),x_laser(e+1)],[y_laser(e),y_laser(e+1)],'Color','y','LineWidth',0.75);
                time_yellow = time_yellow + 1;
            end
            hold on;
            
    %detecting region between 6-4 ring
    %changing colour to green and gining cancel shot to false;
    else
            cancel_shot = 1;
            time_green = time_green + 1;
            plot([x_laser(e),x_laser(e+1)],[y_laser(e),y_laser(e+1)],'Color','g','LineWidth',0.75);
            hold on;
    end
end



%%%%%%%%%%----------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%--Calculation of score & plot of shot ------------%%%%%%%%%%%%%%%%%%%%%%%%%

pelletCenter = zeros(1,2);
pelletRadii = pixelPerMM*4.5;
tenDiv = tenRing/9;
shot = zeros(length(shot_cor),1);

for k = 1:length(shot_cor)
    if(k ~= 1)
        if (shot_cor(k) > 0 && (shot_cor(k)-shot_cor(k-1) > std(shot_cor)/2))
            pelletCenter(1) = x_laser(shot_cor(k));
            pelletCenter(2) = y_laser(shot_cor(k)) - aim_point;
            
            rectangle('Position',[pelletCenter(1)-pelletRadii ((pelletCenter(2)+aim_point)-pelletRadii) 2*pelletRadii 2*pelletRadii],'Curvature',[1 1],'FaceColor','y');
            hold on;
     
            rectangle('Position',[pelletCenter(1)-pelletRadii pelletCenter(2)-pelletRadii 2*pelletRadii 2*pelletRadii],'Curvature',[1 1],'FaceColor','r');
            str = num2str(k);
            text(pelletCenter(1), pelletCenter(2),str,'Color','k','HorizontalAlignment','center');
            hold on;
            
            distanceBetwPelletandCenter = ((centersDark(1) - pelletCenter(1))^2 + (centersDark(2) - pelletCenter(2))^2)^0.5;
            if (distanceBetwPelletandCenter < (tenRing) )
                tempShot = (10.0+((9-(distanceBetwPelletandCenter/tenDiv))/10));
                shot(k) = round(tempShot,1);
   
            else if (distanceBetwPelletandCenter >= tenRing && (distanceBetwPelletandCenter-(pelletRadii)) < oneRing)
                tempShot = 10-(((distanceBetwPelletandCenter-(pelletRadii))-tenRing)/diffBetween2rings);
                shot(k) = round(tempShot,1);
            else
                shot(k) = 0;
                end
            end
            
%                         shot_str = ['Shot ',str,' ',num2str(shot(k))];
%                       annotation('textbox','String',shot_str);
                      

        end
       
    elseif (shot_cor(k) > 0)
        pelletCenter(1) = x_laser(shot_cor(k));
        pelletCenter(2) = y_laser(shot_cor(k)) - aim_point;
        
        rectangle('Position',[pelletCenter(1)-pelletRadii ((pelletCenter(2)+aim_point)-pelletRadii) 2*pelletRadii 2*pelletRadii],'Curvature',[1 1],'FaceColor','y');
        hold on;
     
        rectangle('Position',[pelletCenter(1)-pelletRadii pelletCenter(2)-pelletRadii 2*pelletRadii 2*pelletRadii],'Curvature',[1 1],'FaceColor','r');
        str = num2str(k);
        text(pelletCenter(1), pelletCenter(2),str,'Color','k','HorizontalAlignment','center');
        hold on;
        
        distanceBetwPelletandCenter = ((centersDark(1) - pelletCenter(1))^2 + (centersDark(2) - pelletCenter(2))^2)^0.5;
            if (distanceBetwPelletandCenter < (tenRing) )
                tempShot = (10.0+((9-(distanceBetwPelletandCenter/tenDiv))/10));
                shot(k) = round(tempShot,1);
   
            else
                if (distanceBetwPelletandCenter >= tenRing && (distanceBetwPelletandCenter-(pelletRadii)) < oneRing)
                    tempShot = 10-(((distanceBetwPelletandCenter-(pelletRadii))-tenRing)/diffBetween2rings);
                    shot(k) = round(tempShot,1);
                else
                    shot(k) = 0;
                end
                
            end
            
%                      
                      
                     
                        
            
    end
    
    
end

if(shot(1) > 0)
    uitable('Data',[1 shot(1);2 shot(2);3 shot(3)],'ColumnName',{ 'Shot','Score'},'Position',[30 300 150 80]);
end

%find the time gun was in correct region
time_green = time_green/frame_rate;

time_yellow = time_yellow/frame_rate;

time_red = time_red/frame_rate;

time_marron = time_marron/frame_rate;

%time_col = [time_red, time_yellow, time_green, time_marron];
%fig = figure;
uit = uitable(fig_target);
uit.Position = [30 500 225 125];
uit.Data = {'RED' time_red 'Start';'YELLOW' time_yellow 'Ready';'GREEN' time_green 'Fire';'MAROON' time_marron 'Cancel'};
uit.ColumnName = {'Position','Time','Indication'};

figure;

%%%%%%%%%---------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%------Speed of the movement of the gun---------%%%%%%%%%%%%%%

slope = zeros(length(x_laser),1);
time_sec = zeros(length(slope),1);

for i = 1:length(x_laser)-1
    
    %rate of change of movement
    slope(i) = abs((y_laser(i+1) - y_laser(i))/(x_laser(i+1) - x_laser(i)));
    slope(i) = slope(i)/pixelPerMM;
    
    %time elapsed as frame moves
    time_sec(i) = i/frame_rate;
    
end

%Plot the speed of the movement
plot(time_sec,slope);
axis([0 Duration 0 100]);
xlabel('time in  seconds');
ylabel('mm/sec');
title('Speed of the movement of the Gun');
end