function colormapOut = oct_get_colormap(map, varargin)
% Creates colormaps that are adequate to display images in SS-OCT system. Also
% creates maps adequate for photoacoustic tomography, OIS & NIRS.
% SYNTAX:
% colormapOut = oct_get_colormap(map, nColors)
% INPUTS:
% map           String that describes the colormap to retrieve:
%               'octgold'
%               'fdrainbow'
%               'tdrainbow'
%               'wob'
%               'bow'
%               'flow'
%               'rwbdoppler'
%               'bwrdoppler'
%               'robdoppler'
%               'bordoppler'
%               'redmap'
%               'greenmap'
%               'bluemap'
%               'kredmap'
%               'kgreenmap'
%               'kbluemap'
%               'purplemap'
%               'redbluecmap'
%               'so2'
%               'bipolar'
%               'warm'
%               'cold'
%               'linlhot' 
%               'isol' 
%               'cubicl' 
%               'edge' 
%               'cubicyf' 
%               'linearl'
% nColors       Integer number of RGB triplets to be generated, default is
%               256 color levels
% OUTPUTS:
% colormapOut   3 columns matrix, which values are in the range from 0 to 1.
%_______________________________________________________________________________
% Copyright (C) 2013 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
% Edgar Guevara
% 2013/05/22
% ------------------------------------------------------------------------------
% Optional inputs handling
% ------------------------------------------------------------------------------
% only want 1 optional input at most
numvarargs                  = length(varargin);
if numvarargs > 1
    error('ioi_get_colormap', ...
        'Requires at most 2 optional inputs');
end
% set defaults for optional inputs
optargs                     = { 256 };
% now put these defaults into the optargs cell array, and overwrite the ones
% specified in varargin.
optargs(1:numvarargs)       = varargin;
% Place optional args in memorable variable names
ColorMapSize   = optargs{:};
% ------------------------------------------------------------------------------

ColorMapSize = fix(ColorMapSize/2);
% ColorMapSize = 256/2;

switch lower(map)
    case 'octgold'
        % OCT Gold: typical high contrast, high dynamic OCT map
        x = [0 7 60 108 157 190 224 253 254 255] + 1;
        rgb = [ ...
            0.00392157  0.00392157  0.0156863;
            0.0352941   0           0;
            0.376471    0.105882    0;
            0.678431    0.337255    0;
            0.992157    0.701961    0.203922;
            0.992157    0.878431    0.341176;
            0.996078    0.996078    0.482353;
            0.94902     0.996078    0.603922;
            0.905882    0.952941    0.607843;
            0.905882    0.952941    0.607843];
    case 'fdrainbow'
        % Fourier-Domain Rainbow: multi-colour, high dynamic range colour map for
        % novel OCT systems
        x = [0 22 53 68 106 141 168 194 245 255] + 1;
        rgb = [ ...
            0.00392157  0.00392157  0.0156863;
            0.0313725   0.0313725   0.117647;
            0.00392157  0.113725    0.541176;
            0.203922    0.486275    0.207843;
            0.294118    0.780392    0.145098;
            0.847059    0.752941    0.435294;
            1           0.966912    0.0735296;
            0.992157    0.792157    0.411765;
            1           0.3         0.3;
            1           0.984314    0.984314];
    case 'tdrainbow'
        % Time-Domain Rainbow: mimicking the old time domain high dynamic range
        % colour map found in the commercial devices
        x = [32 64 78 138 221 255] + 1;
        rgb = [ ...
            0.00392157  0.00392157  0.0156863;
            0.3         0.3         1;
            0.176471    0.760784    0.254902;
            1           1           0.301961;
            1           0.3         0.3;
            1           0.984314    0.984314];
    case 'wob'
        % grey-scale with transparency for frequency domain OCT data
        x = [0 40 72 136 255] + 1;
        rgb = [...
            0.00392157  0.00392157  0.0156863;
            0           0           0;
            0.301961    0.301961    0.301961;
            0.733333    0.733333    0.733333;
            1           1           1];
    case 'bow'
        % grey-scale with transparency for frequency domain OCT data (not very
        % commonly used by the community, but good for faint signals)
        x = [0 35 96 148 255] + 1;
        rgb = [...
            1           1           1;
            0.890196    0.890196    0.890196;
            0.584314    0.584314    0.584314;
            0.282353    0.282353    0.282353;
            0           0           0];
    case 'flow'
        % High flow velocity contrast 20kHz
        x = [0 69 128 184 255] + 1;
        rgb = [...
            0.133333    0.188235    1;
            0.301961    0.760784    1;
            0.286275    0.913725    0.27451;
            0.972549    1           0.0862745;
            1           0.1         0.1];
    case 'purplemap'
        % Single color luminance changes from purple to white
        x = [0 255] + 1;
        rgb = [...
            0.3412      0           0.4980;
            1           1           1];
    case 'rwbdoppler'
        % Red on blue, with white background for Doppler imaging
        % Also for SO2 contrast in photoacosutics
        minColor    = [0 0 1]; % blue
        medianColor = [1 1 1]; % white   
        maxColor    = [1 0 0]; % red      
       
        int1 = zeros(ColorMapSize,3); 
        int2 = zeros(ColorMapSize,3);
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'bwrdoppler'
        % Blue on red, with white background for Doppler imaging
        minColor    = [1 0 0]; % red
        medianColor = [1 1 1]; % white
        maxColor    = [0 0 1]; % blue
        
        int1 = zeros(ColorMapSize,3);
        int2 = zeros(ColorMapSize,3);
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'robdoppler'
        % Red on blue, with black background for Doppler imaging
        minColor    = [0 0 1]; % blue
        medianColor = [0 0 0]; % white   
        maxColor    = [1 0 0]; % red      

        int1 = zeros(ColorMapSize,3); 
        int2 = zeros(ColorMapSize,3);
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'bordoppler'
        % Blue on red, with black background for Doppler imaging
        minColor    = [1 0 0]; % red
        medianColor = [0 0 0]; % black
        maxColor    = [0 0 1]; % blue
        
        int1 = zeros(ColorMapSize,3);
        int2 = zeros(ColorMapSize,3);
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'so2'
        % Red on blue, sO2 PAT imaging
        minColor    = [0 0 1]; % blue
        medianColor = [0.5 0 0.5]; % ??
        maxColor    = [1 0 0]; % red
        
        int1 = zeros(ColorMapSize,3);
        int2 = zeros(ColorMapSize,3);
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'redbluecmap'
        % red represents values above the mean, white represents the mean, and
        % blue represents values below the mean
        colormapOut = redbluecmap;
        return
    case 'redmap'
        % Red map for HbT contrast in PAT, from VisualSonics
        minColor    = [0 0 0]; % black
        medianColor = [1 0 0]; % red
        maxColor    = [1 1 1]; % white
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'greenmap'
        % Green map
        minColor    = [0 0 0]; % black
        medianColor = [0 1 0]; % green
        maxColor    = [1 1 1]; % white
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'bluemap'
        % Blue map
        minColor    = [0 0 0]; % black
        medianColor = [0 0 1]; % blue
        maxColor    = [1 1 1]; % white
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'kredmap'
        % % Single color luminance changes from black to red
        x = [0 255] + 1;
        rgb = [...
            0           0           0;
            1           0           0];
    case 'kgreenmap'
        % % Single color luminance changes from black to green
        x = [0 255] + 1;
        rgb = [...
            0           0           0;
            0           1           0];
    case 'kbluemap'
        % % Single color luminance changes from black to blue
        x = [0 255] + 1;
        rgb = [...
            0           0           0;
            0           0           1];
    case 'bipolar'
        colormapOut = bipolar(2*ColorMapSize, 1/3);
        return
    case 'warm'
        colormapOut = bipolar(4*ColorMapSize, 1/3);
        colormapOut = colormapOut((end/2)+1:end,:);
        return
    case 'cold'
        colormapOut = bipolar(4*ColorMapSize, 1/3);
        colormapOut = colormapOut(1:(end/2),:);
        return
    case {'linlhot' 'isol' 'cubicl' 'edge' 'cubicyf' 'linearl'}
        % perceptually balanced colormaps
        colormapOut = pmkmp(2*ColorMapSize, map);
        return
    otherwise
        % Inverted linear gray colormap
        colormapOut = flipud(colormap(gray(2*ColorMapSize)));
        return
end

%% Calculate colormap
% ----------------------- Piecewise linear interpolation -----------------------
nSegments           = numel(x) - 1;
samplesPerSegment   = diff(x);
colormapOut         = zeros([sum(samplesPerSegment) 3]);

for iSegments = 1:nSegments,
    for iColors = 1:3,
    colormapOut(x(iSegments):x(iSegments+1),iColors) = linspace(rgb(iSegments,iColors),...
        rgb(iSegments+1,iColors),...
        samplesPerSegment(iSegments)+1);
    end
end

% --------------- uint8 array to export colormaps to LabView -------------------
% colormapOut = uint8(round(colormapOut*255));
% figure; plot(colormapOut)

% ---------------------------- Spline interpolation ----------------------------
% colormapOut(:,1) = spline(x, rgb(:,1), (x(1):x(end))');
% colormapOut(:,2) = spline(x, rgb(:,2), (x(1):x(end))');
% colormapOut(:,3) = spline(x, rgb(:,3), (x(1):x(end))');
% colormapOut(colormapOut<0) = 0;         % Get rid of negative numbers
% colormapOut(colormapOut>1) = 1;         % Truncate to 1
% figure; plot(colormapOut)

%% OCT Gold Alpha channel
% x                   = [0; 22; 70; 123; 251] + 1;
% alphaValues         = [0; 0; 0.0543478; 0.717391; 1];
% nPoints             = numel(x);
% nSegments           = nPoints - 1;
% samplesPerSegment   = diff(x);
% OCTgoldAlphaMap     = zeros([sum(samplesPerSegment) 1]);
% 
% for iSegments = 1:nSegments,
%     OCTgoldAlphaMap(x(iSegments):x(iSegments+1)) = linspace(alphaValues(iSegments),...
%         alphaValues(iSegments+1),...
%         samplesPerSegment(iSegments)+1);
% end

% ==============================================================================

function cm = bipolar(m, n, interp)
%bipolar: symmetric/diverging/bipolar colormap, with neutral central color.
%
% Usage: cm = bipolar(m, neutral, interp)
%  neutral is the gray value for the middle of the colormap, default 1/3.
%  m is the number of rows in the colormap, defaulting to copy the current
%    colormap, or the colormap that MATLAB defaults for new figures.
%  interp is the method used to interpolate the colors, see interp1.
%
% The colormap goes from cyan-blue-neutral-red-yellow if neutral is < 0.5
% (the default) and from blue-cyan-neutral-yellow-red if neutral > 0.5.
%
% If neutral is exactly 0.5, then a map which yields a linear increase in
% intensity when converted to grayscale is produced (as derived in
% colormap_investigation.m). This colormap should also be reasonably good
% for colorblind viewers, as it avoids green and is predominantly based on
% the purple-yellow pairing which is easily discriminated by the two common
% types of colorblindness. For more details on this, see Brewer (1996):
% http://www.ingentaconnect.com/content/maney/caj/1996/00000033/00000002/art00002
% 
% Examples:
%  surf(peaks)
%  cmx = max(abs(get(gca, 'CLim')));
%  set(gca, 'CLim', [-cmx cmx]);
%  colormap(bipolar)
%
%  imagesc(linspace(-1, 1,201)) % symmetric data, if not set symmetric CLim
%  colormap(bipolar(201, 0.1)) % dark gray as neutral
%  axis off; colorbar
%  pause(2)
%  colormap(bipolar(201, 0.9)) % light gray as neutral
%  pause(2)
%  colormap(bipolar(201, 0.5)) % grayscale-friendly colormap
%
% See also: colormap, jet, interp1, colormap_investigation, dusk
% dusk is a colormap like bipolar(m, 0.5), in Oliver Woodford's real2rgb:
%  http://www.mathworks.com/matlabcentral/fileexchange/23342
%
% Copyright 2009 Ged Ridgway at gmail com
% Based on Manja Lehmann's hand-crafted colormap for cortical visualisation

if ~exist('interp', 'var')
    interp = [];
end

if ~exist('n', 'var') || isempty(n)
    n = 1/3;
end

if ~exist('m', 'var') || isempty(m)
    if isempty(get(0, 'CurrentFigure'))
        m = get(0, 'DefaultFigureColormap');
    else
        m = get(gcf, 'Colormap');
    end
    m = size(m, 1);
end

if n < 0
    % undocumented rainbow-variant colormap, not recommended, as explained 
    % by Borland & Taylor (2007) in IEEE Computer Graphics & Applications,
    % http://doi.ieeecomputersociety.org/10.1109/10.1109/MCG.2007.46
    if isempty(interp)
        interp = 'cubic'; % linear produces bands at pure green and yellow
    end
    n = abs(n);
    cm = [
        0 0 1
        0 1 0
        n n n
        1 1 0
        1 0 0
        ];
elseif n < 0.5
    if isempty(interp)
        interp = 'linear'; % seems to work well with dark neutral colors
    end
    cm = [
        0 1 1
        0 0 1
        n n n
        1 0 0
        1 1 0
        ];
elseif n > 0.5
    if isempty(interp)
        interp = 'cubic'; % seems to work better with bright neutral colors
    end
    cm = [
        0 0 1
        0 1 1
        n n n
        1 1 0
        1 0 0
        ];
else % exactly 0.5, use the brew2 scheme from colormap_investigation
    if isempty(interp)
        interp = 'linear';
    end
    if ~strcmp(interp, 'linear')
        warning('bipolar:nonlinearluminance', ...
            'Nonlinear interpolation will not preserve linear luminance!')
    end
    cm = [
        0.2157         0    0.3207
        0.0291    0.3072    1.0000
        0.5000    0.5000    0.5000
        1.0000    0.6035    0.3992
        0.9944    0.9891    0.1647
        ];
end

if m ~= size(cm, 1)
    xi = linspace(1, size(cm, 1), m);
    cm = interp1(cm, xi, interp);
end

function map=pmkmp(n,scheme)
% PMKMP Returns perceptually balanced colormaps with rainbow-like colors
%   PMKMP(N,SCHEME) returns an Nx3 colormap. 
%   usage: map=pmkmp(n,scheme);
%
% JUSTIFICATION: rainbow, or spectrum color schemes are considered a poor
% choice for scientific data display by many in the scientific community
% (see for example reference 1 and 2) in that they introduce artifacts 
% that mislead the viewer. "The rainbow color map appears as if its separated
% into bands of almost constant hue, with sharp transitions between hues. 
% Viewers perceive these sharp transitions as sharp transitions in the data,
% even when this is not the casein how regularly spaced (interval) data are
% displayed (quoted from reference 1). This submission is intended to share
% the results of my work to create more perceptually balanced, 
% rainbow-like color maps. Please see output arguments section for descriptions.
%
%
%   arguments: (input)
%   scheme - can be one of the following strings:
%     'IsoL'      Lab-based isoluminant rainbow with constant luminance L*=60
%                  For interval data displayed with external lighting
%
%     'LinearL'	  Lab-based linear lightness rainbow. 
%                  For interval data displayed without external lighting
%                  100% perceptual
% 
%     'LinLhot'	  Linear lightness modification of Matlab's hot color palette. 
%                  For interval data displayed without external lighting
%                  100% perceptual    
%
%     'CubicYF'	   Lab-based rainbow scheme with cubic-law luminance(default)
%                  For interval data displayed without external lighting
%                  100% perceptual
%
%     'CubicL'	   Lab-based rainbow scheme with cubic-law luminance
%                  For interval data displayed without external lighting
%                  As above but has red at high end (a modest deviation from
%                  100% perceptual)
%
%     'Edge'       Diverging Black-blue-cyan-white-yellow-red-black scheme
%                  For ratio data (ordered, constant scale, natural zero)  
%
%   n - scalar specifying number of points in the colorbar. Maximum n=256
%      If n is not specified, the size of the colormap is determined by the
%      current figure. If no figure exists, MATLAB creates one.
%
%
%   arguments: (output)
%   map - colormap of the chosen scheme
%   - IsoL is based on work in paper 2 in the reference section.
%     In both this paper and in several others this is indicated as the
%     best for displaying interval data with external lighting.
%     This is so as to allow the lighting to provide the shading to
%     highlight the details of interest. If lighting is combined with a
%     colormap that has its own luminance function associated - even as
%     simple as a linear increase this will confuse the viewer. The only 
%     difference from the paper is that I changed the value of constant 
%     luminance to L*=60 to make it brighter that the authors' example.
%
%   - LinearL is a linear lightness modification of another palette from 
%     paper 2 in the reference. For how it was generated see my blog post:
%     mycarta.wordpress.com/2012/12/06/the-rainbow-is-deadlong-live-the-rainbow-part-5-cie-lab-linear-l-rainbow/
% 
%   - LinLhot is a linear lightness modification of Matlab's hot 
%     color palette. For how it was generated see my blog post:
%     mycarta.wordpress.com/2012/10/14/the-rainbow-is-deadlong-live-the-rainbow-part-4-cie-lab-heated-body/          
%
%   - CubicL too is based on some of the ideas in paper 2 in the 
%      reference section but rather than using a linearly increasing
%      L* function such as the one used by those authors, I am
%      using a compressive or cubic law function for the increase in 
%      L*.  L* ranges between 31 and 90 in the violet to yellowish 
%      portion of the colormap, then decreases to about 80 to get 
%      to the red (please refer to figure L_a_b_PlotsCubicL.png).
%      The choice to start at 31 was a matter of taste. 
%      I like having violet instead of black at the cold end of the
%      colormap. The latter choice was so as to have red and not
%      white at the warm end  of the colorbar, which is also a 
%      matter of personal taste. As a result,  there is an inversion in 
%      the L* trend, but I believe because it is a smooth one that
%      this is an acceptable compromise and the resulting
%      colormap is much of an improvement over the standard 
%      rainbow or spectrum schemes, which  typically have at least 3 sharp 
%      L* inversions. Please run CompareLabPlotsUsingColorspace.m or see
%      figures: L_plot_for_CubicL_colormap.png, L_plot_for_jet_colormap.png,
%      and L_plot_for_spectrum_colormap.png for a demonstration
%
%    - CubicYF A fully perceptual version of the above in which I eliminated
%      the red tip at the high end. The work is described in papers 12 and 13. 
%      I've uploaded 2 figures. The first, spectrum vs cubicYF.png, is a comparison
%      of lightness versus sample number for the spectrum (top left) and the
%      new color palette (bottom left), and also a comparison of test surface
%      (again the Great Pyramid of Giza)using the spectrum (top right)and 
%      the new color palette (bottom right). The second figure 
%      simulations color vision deficieny.png
%      is a comparison of spectrum and cubicYF rainbow for all viewers. 
%      Left column: full color vision  for the spectrum (top left) and for the 
%      cubeYF rainbow (bottom left). Centre column: simulation of Deuternaopia
%      for spectrum (top centre) and cubeYF rainbow (bottom centre).
%      Right column: simulation of Tritanopia for spectrum (top right) and
%      cubeYF rainbow (bottom right). For the cubeYF there are no
%      confusing color pairs in these simulations. There are several in the
%      spectrum. Please refer to reference 14 for vcolor vision deficiency
%      terminoligy. For how it was generated see my blog post:
%      http://mycarta.wordpress.com/2013/02/21/perceptual-rainbow-palette-the-method/
%
%
%   - Edge is based on the Goethe Edge Colors described in the book in 
%     reference 3. In practice the colormap resembles a cold color map attached
%     to a warm color map. But the science behind it is rigorous and the
%     experimental work is based on is very intriguing to me: an alternative
%     to the Newtonian spectrum. This is not perceptually balanced in a
%     strict sense but because it does not have green it is perceptually
%     improved in a harmonious sense (refer to paper reference 10 for a review
%     of the concept of harmony in color visualization).
%
%
%
%   Example: 128-color rainbow with cubic-law luminance (default)
%     %  load mandrill;
%     %  imagesc(X);
%     %  colormap(pmkmp(128));
%     %  colorbar;
%   See files examples.m, examples1.m, and example2.m for more examples 
%   See files MakeLabPlotUsingColorspace.m and CompareLabPlotsUsingColorspace.m 
%   for some demonstrations
%
%
%   See also: JET, HSV, GRAY, HOT, COOL, BONE, COPPER, PINK, FLAG, PRISM,
%             COLORMAP, RGBPLOT
% 
%
%   Other submissions of interest
% 
%     Haxby color map
%     www.mathworks.com/matlabcentral/fileexchange/25690-haxby-color-map
% 
%     Colormap and colorbar utilities
%     www.mathworks.com/matlabcentral/fileexchange/24371-colormap-and-color
%     bar-utilities-sep-2009
% 
%     Lutbar
%     www.mathworks.com/matlabcentral/fileexchange/9137-lutbar-a-pedestrian-colormap-toolbarcontextmenu-creator
% 
%     usercolormap
%     www.mathworks.com/matlabcentral/fileexchange/7144-usercolormap
% 
%     freezeColors
%     www.mathworks.com/matlabcentral/fileexchange/7943
%
%
%     Bipolar Colormap
%     www.mathworks.com/matlabcentral/fileexchange/26026
%
%     colorGray
%     www.mathworks.com/matlabcentral/fileexchange/12804-colorgray
%
%     mrgb2gray
%     www.mathworks.com/matlabcentral/fileexchange/5855-mrgb2gray
%
%     CMRmap
%     www.mathworks.com/matlabcentral/fileexchange/2662-cmrmap-m
%
%     real2rgb & colormaps
%     www.mathworks.com/matlabcentral/fileexchange/23342-real2rgb-colormaps
%
%   Acknowledgements
% 
%     For input to do this research I was inspired by: 
%     ColorSpiral - http://bsp.pdx.edu/Software/ColorSpiral.m
%     Despite an erroneous assumption about conversion/equivalence to 
%     grayscale (which CMRmap achieves correctly) the main idea is ingenious
%     and the code is well written. It also got me interested in perceptual
%     colormaps. See reference 5 for paper
%     
%     For function architecture and code syntax I was inspired by:
%     Light Bartlein Color Maps 
%     www.mathworks.com/matlabcentral/fileexchange/17555
%     (and comments posted therein)
% 
%     For idea on world topgraphy in examples.m I was inspired by:
%     Cold color map
%     www.mathworks.cn/matlabcentral/fileexchange/23865-cold-colormap
%
%     To generate the spectrum in examples1.m I used:
%     Spectral and XYZ Color Functions
%     www.mathworks.com/matlabcentral/fileexchange/7021-spectral-and-xyz-color-functions
%     
%     For Lab=>RGB conversions I used:
%     Colorspace transforamtions
%     www.mathworks.com/matlabcentral/fileexchange/28790-colorspace-transformations
%
%
%     For the figures in example 2 I used:
%     Shaded pseudo color
%     http://www.mathworks.cn/matlabcentral/fileexchange/14157-shaded-pseudo-color
%
%     For plots in CompareLabPlotsUsingColorspace.m I used:
%     cline
%     http://www.mathworks.cn/matlabcentral/fileexchange/14677-cline
%
%     For some ideas in general on working in Lab space:
%     Color scale
%     www.mathworks.com/matlabcentral/fileexchange/11037
%     http://blogs.mathworks.com/steve/2006/05/09/a-lab-based-uniform-color-scale/
%
%     A great way to learn more about improved colormaps and making colormaps:
%     MakeColorMap
%     www.mathworks.com/matlabcentral/fileexchange/17552
%     blogs.mathworks.com/videos/2007/11/15/practical-example-algorithm-development-for-making-colormaps/
%
%
%  References
% 
%     1)  Borland, D. and Taylor, R. M. II (2007) - Rainbow Color Map (Still) 
%         Considered Harmful
%         IEEE Computer Graphics and Applications, Volume 27, Issue 2
%         Pdf paper included in submission
% 
%     2)  Kindlmann, G. Reinhard, E. and Creem, S. Face-based Luminance Matching
%         for Perceptual Colormap Generation
%         IEEE - Proceedings of the conference on Visualization '02
%         www.cs.utah.edu/~gk/papers/vis02/FaceLumin.pdf
% 
%     3)  Koenderink, J. J. (2010) - Color for the Sciences
%         MIT press, Cambridge, Massachusset
% 
%     4)  Light, A. and Bartlein, P.J. (2004) - The end of the rainbow? 
%         Color schemes for improved data graphics.
%         EOS Transactions of the American Geophysical Union 85 (40)
%         Reprint of Article with Comments and Reply
%         http://geography.uoregon.edu/datagraphics/EOS/Light-and-Bartlein.pdf
% 
%     5)  McNames, J. (2006) An effective color scale for simultaneous color
%         and gray-scale publications
%         IEEE Signal Processing Magazine, Volume 23, Issue1
%         http://bsp.pdx.edu/Publications/2006/SPM_McNames.pdf
%
%     6)  Rheingans, P.L. (2000), Task-based Color Scale Design
%         28th AIPR Workshop: 3D Visualization for Data Exploration and Decision Making
%         www.cs.umbc.edu/~rheingan/pubs/scales.pdf.gz
% 
%     7)  Rogowitz, B.E. and  Kalvin, A.D. (2001) - The "Which Blair project":
%         a quick visual method for evaluating perceptual color maps. 
%         IEEE - Proceedings of the conference on Visualization 01
%         www.research.ibm.com/visualanalysis/papers/WhichBlair-Viz01Rogowitz_Kalvin._final.pdf
% 
%     8)  Rogowitz, B.E. and  Kalvin, A.D. - Why Should Engineers and Scientists
%         Be Worried About Color?
%         www.research.ibm.com/people/l/lloydt/color/color.HTM
% 
%     9)  Rogowitz, B.E. and  Kalvin, A.D. - How NOT to Lie with Visualization
%         www.research.ibm.com/dx/proceedings/pravda/truevis.htm
%
%     10) Wang, L. and Mueller,K (2008) - Harmonic Colormaps for Volume Visualization
%         IEEE/ EG Symposium on Volume and Point-Based Graphics
%         http://www.cs.sunysb.edu/~mueller/papers/vg08_final.pdf
%
%     11) Wyszecki, G. and Stiles W. S. (2000) - Color Science: Concepts and 
%         Methods, Quantitative Data and Formulae, 2nd Edition, John Wiley and Sons
% 
%     12) Niccoli, M., (2012) - How to assess a color map - in:
%         52 things you should know about Geophysics, M. Hall and E. Bianco,
%         eds. 
%
%     13) Niccoli, M., and Lynch, S. (2012, in press) - A more perceptual color
%         palette for structure maps, 2012 CSEG Geoconvention extended
%         abstract.
%
%     14) Color Blind Essentials eBook
%         http://www.colblindor.com/color-blind-essentials/
%
%  Author: Matteo Niccoli
%  e-mail address: matteo@mycarta.ca
%  Release: 3.0
%  Release date: February 2013
%  Full research at:
%  http://mycarta.wordpress.com/2012/05/29/the-rainbow-is-dead-long-live-the-rainbow-series-outline/


% error checking, defaults, valid schemes
error(nargchk(0,2,nargin))
error(nargoutchk(0,1,nargout))

if nargin<2
  scheme = 'CubicYF';
end
if nargin<1
  n = size(get(gcf,'colormap'),1);
end
if n>256
error('Maximum number of 256 points for colormap exceeded');
end

switch lower(scheme)
    case 'isol'
        baseMap = IsoL;
    case 'cubicl'
        baseMap = CubicL;
    case 'edge'
        baseMap = Edge;
    case 'cubicyf'
        baseMap = CubicYF;
    case 'linlhot'
        baseMap = LinLhot;
    case 'linearl'
        baseMap = LinearL;
    otherwise
        error(['Invalid scheme ' scheme])
end
idx1 = linspace(1,n,size(baseMap,1));
idx2 = 1:1:n;
map = interp1(idx1,baseMap,idx2,'cubic');


function baseMap = Edge
baseMap =    [0 0 0;
              0 0 1;
              0 1 1;
              1 1 1;
              1 1 0;
              1 0 0
              0 0 0];

function baseMap = IsoL
baseMap =   [0.9102    0.2236    0.8997
             0.4027    0.3711    1.0000
             0.0422    0.5904    0.5899
             0.0386    0.6206    0.0201
             0.5441    0.5428    0.0110
             1.0000    0.2288    0.1631];
 
function baseMap = CubicL
 baseMap =  [0.4706         0    0.5216;
             0.5137    0.0527    0.7096;
             0.4942    0.2507    0.8781;
             0.4296    0.3858    0.9922;
             0.3691    0.5172    0.9495;
             0.2963    0.6191    0.8515;
             0.2199    0.7134    0.7225;
             0.2643    0.7836    0.5756;
             0.3094    0.8388    0.4248;
             0.3623    0.8917    0.2858;
             0.5200    0.9210    0.3137;
             0.6800    0.9255    0.3386;
             0.8000    0.9255    0.3529;
             0.8706    0.8549    0.3608;
             0.9514    0.7466    0.3686;
             0.9765    0.5887    0.3569];
         
function baseMap = CubicYF
 baseMap =  [0.5151    0.0482    0.6697
             0.5199    0.1762    0.8083
             0.4884    0.2912    0.9234
             0.4297    0.3855    0.9921
             0.3893    0.4792    0.9775
             0.3337    0.5650    0.9056
             0.2795    0.6419    0.8287
             0.2210    0.7123    0.7258
             0.2468    0.7612    0.6248
             0.2833    0.8125    0.5069
             0.3198    0.8492    0.3956
             0.3602    0.8896    0.2919
             0.4568    0.9136    0.3018
             0.6033    0.9255    0.3295
             0.7066    0.9255    0.3414
             0.8000    0.9255    0.3529];  


function baseMap = LinearL
 baseMap =  [0.0143	0.0143	0.0143
             0.1413	0.0555	0.1256
             0.1761	0.0911	0.2782
             0.1710	0.1314	0.4540
             0.1074	0.2234	0.4984
             0.0686	0.3044	0.5068
             0.0008	0.3927	0.4267
             0.0000	0.4763	0.3464
             0.0000	0.5565	0.2469
             0.0000	0.6381	0.1638
             0.2167	0.6966	0.0000
             0.3898	0.7563	0.0000
             0.6912	0.7795	0.0000
             0.8548	0.8041	0.4555
             0.9712	0.8429	0.7287
             0.9692	0.9273	0.8961]; 


function baseMap = LinLhot
 baseMap =  [0.0225	0.0121	0.0121
             0.1927	0.0225	0.0311
             0.3243	0.0106	0.0000
             0.4463	0.0000	0.0091
             0.5706	0.0000	0.0737
             0.6969	0.0000	0.1337
             0.8213	0.0000	0.1792
             0.8636	0.0000	0.0565
             0.8821	0.2555	0.0000
             0.8720	0.4182	0.0000
             0.8424	0.5552	0.0000
             0.8031	0.6776	0.0000
             0.7659	0.7870	0.0000
             0.8170	0.8296	0.0000
             0.8853	0.8896	0.4113
             0.9481	0.9486	0.7165]; 

function c = redbluecmap(m,varargin)
%REDBLUECMAP creates a red and blue colormap.
%
%   REDBLUECMAP(M) returns an M-by-3 matrix containing a red and blue
%   diverging color palette. M is the number of different colors in the
%   colormap with a minimun of 3 and a maximun of 11. Low values are dark
%   blue, values in the center of the map are white, and high values are
%   dark red. If M is empty, a default value of 11 will be used.
%
%   Example:
% 
%       % Reset the colormap of the current figure, type
%             colormap(redbluecmap)
%
%   See also CLUSTERGRAM, COLORMAP, COLORMAPEDITOR, REDGREENCMAP.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2.4.1 $  $Date: 2008/01/23 21:09:34 $

% Reference: 
% http://colorbrewer.org.

%== Setting default
if nargin < 1 || isempty(m) || ~isnumeric(m)
    m = 11;
end

if ~isscalar(m)
    m = m(:);
end

m = max(abs(fix(m)), 3);
m = min(m, 11);

switch (m)
    case 3
        c = [239	138     98;
             247	247     247;
             103	169     207];
    case 4
        c = [202	0       32;
             244	165     130;
             146	197     222;
             5      113     176];
    case 5
        c = [202	0       32;
             244	165     130;
             247	247     247;
             146	197     222;
             5      113     176];
    case 6
        c = [178	24      43;
             239	138     98;
             253	219     199;
             209	229     240;
             103	169     207;
             33     102     172];
    case 7
        c = [178	24      43;
             239	138     98;
             253	219     199;
            247     247     247;
            209     229     240;
            103     169     207;
            33      102     172];
    case 8
        c = [178	24      43;
             214	96      77;
             244	165     130;
             253	219     199;
             209	229     240;
             146	197     222;
             67     147     195;
             33     102     172];
    case 9
        c = [178	24      43;
             214	96      77;
             244	165     130;
             253	219     199;
             247	247     247;
             209	229     240;
             146	197     222;
             67     147     195;
             33     102     172];
    case 10
        c = [103	0       31;
            178     24      43;
            214     96      77;
            244     165     130;
            253     219     199;
            209     229     240;
            146     197     222;
            67	    147     195;
            33      102     172;
            5       48      97];
    case 11
        c = [103    0       31;
            178     24      43;
            214     96      77;
            244     165     130;
            253     219     199;
            247     247     247;
            209     229     240;
            146     197     222;
            67      147     195;
            33      102     172;
            5       48      97];
end
c = flipud(c/255);
x = round(linspace(1,256,11));
% ----------------------- Piecewise linear interpolation -----------------------
nSegments           = numel(x) - 1;
samplesPerSegment   = diff(x);
colormapOut         = zeros([sum(samplesPerSegment) 3]);

for iSegments = 1:nSegments,
    for iColors = 1:3,
    colormapOut(x(iSegments):x(iSegments+1),iColors) = linspace(c(iSegments,iColors),...
        c(iSegments+1,iColors),...
        samplesPerSegment(iSegments)+1);
    end
end
c = colormapOut;
% ==============================================================================
% [EOF]
