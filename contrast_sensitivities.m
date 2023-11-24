function cs = contrast_sensitivities( animal )
% contrast_sensitivities. Returns requested contrast sensitivity table
%
%  CS = contrast_sensitivities( ANIMAL='mouse' )
%      ANIMAL can be gray_squirrel, human, cat, rat, albino_rat, mouse
%
% 2003-2023, Alexander Heimel

if nargin<1 || isempty(animal)
    animal = 'mouse';
end

sfs = logspace(-2,2,100);

% Western gray squirrel (sciurus griseus), 
% Jacobs, Birch and Blakeslee, 1982
% average luminance 3.4 cd/m^2
% distance 30 cm
% vertical gratings
%    
% Eastern gray squirrel (sciurus carolinensis)
% Jacobs, Birch and Blakeslee, 1982

cs_western_gray_squirrel=...
    [ -2 -0.80 0.00 1.25 1.70 2.05 2.30 2.70   3.2   6  12 24;
      -1  2.30 3.00 3.15 2.35 1.95 0.90 0.10  -0.9  -1 -1 -1]; 

cs_western_gray_squirrel(1,:)=...
	from_logplot(cs_western_gray_squirrel(1,:),0.2,2.5,1.25);

cs_western_gray_squirrel(2,:)=...
	from_logplot(cs_western_gray_squirrel(2,:),2,2.5,1.25);
    
% much better at 340 cd/m^2    

cs_squirrel(1,:)=sfs;
cs_squirrel(2,:)=50*sfs.^0.6.*exp( -sfs.^2/0.8^2);

% from Heywood, Petry, Casagrande, 1983
cs_human(1,:)=sfs;
cs_human(2,:)=55*sfs.^0.5.*exp( -sfs.^2/20^2);

% from Heywood, Petry, Casagrande, 1983
cs_cat(1,:)=sfs;
cs_cat(2,:)=250*sfs.^0.6.*exp(-sfs.^2/0.9^2);

% from Heywood, Petry, Casagrande, 1983
cs_hooded_rat(1,:)=sfs;
cs_hooded_rat(2,:)=30*sfs.^0.2.*exp(-sfs.^2/0.55^2);
cs_rat=cs_hooded_rat;

% from Heywood, Petry, Casagrande, 1983
% not accurate at all
cs_albino_rat(1,:)=sfs;
cs_albino_rat(2,:)=20*sfs.^0.2.*exp(-sfs.^2/0.25^2);

% random uess knownin limit is 0.6cpd (rat 1cpd)
cs_mouse(1,:)=sfs;
cs_mouse(2,:)=25*(sfs/0.6).^0.2.*exp(-(sfs/0.6).^2/0.55^2);

switch lower(animal)
    case 'western gray squirrel'
        cs = cs_western_gray_squirrel;
    case 'squirrel'
        cs = cs_squirrel;
    case 'mouse'
        cs = cs_mouse;
    case 'human'
        cs = cs_human;
    case 'cat'
        cs = cs_cat;
    case 'rat'
        cs = cs_rat;
    case 'albino rat'
        cs = cs_albino_rat;
    otherwise
        disp('CONTRAST_SENTITIVITIES: Unknown animal');
        return
end

if nargout == 0
    figure;
    hold
    plot( cs_western_gray_squirrel(1,:),cs_western_gray_squirrel(2,:),'o');
    set(gca,'XScale','log');
    set(gca,'YScale','log');
    set(gca,'XLim',[0.1 100]);
    set(gca,'YLim',[1 150]);
    plot(sfs,cs_squirrel(2,:),'b')
    plot(cs_human(1,:),cs_human(2,:),'r')
    plot(cs_cat(1,:),cs_cat(2,:),'k')
    plot(cs_rat(1,:),cs_rat(2,:),'g')
    plot(cs_albino_rat(1,:),cs_albino_rat(2,:),'y')
    plot(cs_mouse(1,:),cs_mouse(2,:),'m')
    xlabel('Spatial frequency');
    ylabel('Contrast sensitivity');
    legend('squirrel (measured)','squirrel','human','cat','rat','albino rat',...
        'mouse','location','eastoutside');
    hold off
end
end

%% Helper functions
function x=from_logplot(lx, from, base, unit) 
%FROM_LOGPLOT converts measured distant to value on logplot
%  
%  X=FROM_LOGPLOT(LX, FROM, BASE, UNIT) 
%    LX measured distance from FROM
%    BASE is base of logplot, UNIT is distance
%    from BASE to BASE^2
  
  x=from*base.^(lx/unit);
end
      
     