function UpdatePlot(varargin)
    
    try 
        for i = 2 : length(varargin) 
            subplot(3, ceil((length(varargin)-1)/3), i-1)
            ax = gca();
            addpoints(ax.Children,varargin{1}.Data(end),varargin{i}.Data(end))    
        end
    catch
%         MakePlot(varargin)
% 
%         for i = 2 : length(varargin)
%             subplot(3, ceil((length(varargin)-1)/3), i-1)
%             ax = gca(); 
%             addpoints(ax.Children,varargin{1}.Data(1:end),varargin{i}.Data(1:end))      
%         end

    end
    
     drawnow;

end
