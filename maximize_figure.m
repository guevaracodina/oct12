function maximize_figure(h, acqui_info)
%% Graphic options
    % Screensize units normalized
    set(0,'Units','normalized')
    % white background
    set(h,'color','w')
    % Complement figure colors
    set(h,'DefaultAxesColor','w',...
        'DefaultAxesXColor','k',...
        'DefaultAxesYColor','k',...
        'DefaultAxesZColor','k',...
        'DefaultTextColor','k',...
        'DefaultLineColor','k')
    % Maximize figure
    screenSize = get(0,'Screensize');
    screenSize = [screenSize(1)  0.0370 ...
        screenSize(3) ...
        screenSize(4)- 0.0370];
    % Change figure name
    set(h, 'Name', acqui_info.base_filename)
    % Normalized units
    set(h, 'Units', 'normalized');
    % Maximize figure
    set(h, 'OuterPosition', screenSize);
end
