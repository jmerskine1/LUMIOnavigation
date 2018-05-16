%produce plots
%clear all
errorFig(incrementNumber) = struct('cdata',[],'colormap',[]);
outvid=VideoWriter(['/Users/Jonny/Documents/Delft/Microsat_Engineering/movies/', 'rangeError']);

open(outvid);
    for i=1:incrementNumber
    
    hold on
    grid on
    %xlim([0 120])
    yyaxis left
    ylim([-5 30])
    title('Error Propogation vs. Distance to Moon')
    xlabel('Epoch')
    ylabel('Error (%)')
    line(1:i,error(1:i))
    plot(i,error(i),'-','linewidth',20) %'markersize',10,'markerfacecolor','b')
    
    yyaxis right
    ylim([0 70000])
    ylabel('Distance to Moon')
    line(1:i,distance(1:i))
    plot(i,distance(i),'-','linewidth',20)
    
    errorFig(i) = getframe(gcf);
    hold off
    writeVideo(outvid,errorFig(i));
    
    end

close(outvid);


