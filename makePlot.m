function MakePlot(varargin)
    close all
    for i = 2 : length(varargin)
        subplot(3,ceil((length(varargin)-1)/3),i-1)
        ax = gca();
        animatedline(ax);
        ax.XLabel.String = varargin{1}.Name +" ["+varargin{1}.Unit+"]";
        ax.YLabel.String = varargin{i}.Name +" ["+varargin{i}.Unit+"]";
        ax.Title.String = varargin{1}.Name+ " vs "+ varargin{i}.Name;
    end
   
    sgtitle('Real Time Plot')

end