%produce plots
%clear all
errorFig(increment) = struct('cdata',[],'colormap',[]);
outvid=VideoWriter(['/Users/Jonny/Documents/Delft/Microsat_Engineering/movies/', 'illuminationError']);

open(outvid);
    for i=1:increment
    
    hold on
    grid on
    xlim([0 180])
    %yyaxis left
    %ylim([0 180])
    title('Error Propogation vs. Illumination of Surface')
    xlabel('Illumination of Surface (^o)')
    ylabel('Error (%)')
    line(1:i,error(1:i))
    plot(i,error(i),'-','linewidth',20) %'markersize',10,'markerfacecolor','b')
    
   % yyaxis right
    %ylim([0 180])
    %ylabel()
    %line(1:i,distance(1:i))
    %plot(i,distance(i),'-','linewidth',20)
    
    errorFig(i) = getframe(gcf);
    hold off
    writeVideo(outvid,errorFig(i));
    
    end

close(outvid);


