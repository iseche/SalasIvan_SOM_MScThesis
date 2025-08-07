% Iván Salas - 2019 - University of Cantabria
% This is the first basic script I wrote in MATLAB for the analysis of technical, mechanical and environmental properties
% of alternative ceramic products, as part of my MSc thesis in Industrial Engineering Research.

clear all
clc

%% Main steps
%% - 1. Data acquisition from Excel file via GUI
arch = uigetfile('*.xls;*xlsx');
if arch == 0
  msgbox('Error loading file. Try to run the script again.', 'Error', 'Error');
  return
end
% Data is supplied with the first row as variables name and first column as sample name
[D, str]=xlsread(arch);
var_names=str(1,1+[1:size(D,2)]);
spl_names=str(1+[1:size(D,1)],1);
% Data structured as demanded by som_toolbox library
sD=som_data_struct(D,'comp_names',var_names,'labels',spl_na
mes);
msgbox(sprintf(('Successfully data loading with %d samples 
and %d variables'),size(D,1),size(D,2))...
,'Completed','custom',imread('https://upload.wikimedia.org/
wikipedia/commons/thumb/f/fb/Yes_check.svg/200pxYes_check.svg.png'));

%% - 2. Data pre-processing and previous map assessment
% As the size of the map is unknown, user is suggested first if they want an study of the optimal size
% based on minimization of quantification (QE) and topographical (TE) errors.
sTopol=som_topol_struct('data',sD);
method=input('Do you want to perform a brief map evaluation 
with different types of normalization? Write "Yes":','s');
n=sTopol.msize(1)-2; m=sTopol.msize(2)-2;
sD1=sD;sD2=sD;sD3=sD;
if strcmp(method,'Yes')==1 || strcmp(method,'yes')==1 || 
strcmp(method,'YES')==1 || strcmp(method,'y')==1
for norm=1:2:5
switch norm
   case 1
   sD=som_normalize(sD1,'range');
   case 3
   sD=som_normalize(sD2,'var');
   case 5
   sD=som_normalize(sD3,'log');
end
 mmin=m; nmin=n; count=1;
 while n<sTopol.msize(1)+2
     count=count+1;
     n=n+1;
     map=som_make(sD,'msize',[n m]);
     [QE,TE]=som_quality(map,sD);
     mat(count,norm+1:norm+2)=[QE,TE];
     sizemap={[num2str(n),char(120),num2str(m)]};
     matstr(count,1)=sizemap;
     while m<sTopol.msize(2)+2
         count=count+1;
         m=m+1;
         map=som_make(sD,'msize',[n m]);
         [QE,TE]=som_quality(map,sD);
         mat(count,norm+1:norm+2)=[QE,TE];
         sizemap={[num2str(n),char(120),num2str(m)]};
         matstr(count,1)=sizemap;
     end
   m=mmin;
   end
n=nmin;
xlswrite('normtest.xlsx',mat); 
xlswrite('normtest.xlsx',matstr)
sD=som_denormalize(sD);
end
xlswrite('normtest.xlsx',{'Map 
size','[QE,TE]','RANGE','[QE,TE]','VAR','[QE,TE]','LOG'})
end

% Choose type of normalization of data
normtype=input('Choose type of normalization ["range", 
"var", "log"] ("range" as default):','s');
if strcmp(normtype,'range')==1
 sD=som_normalize(sD,'range');
elseif strcmp(normtype,'var')==1
 sD=som_normalize(sD,'var');
elseif strcmp(normtype,'log')==1
 sD=som_normalize(sD,'log');
else
 sD=som_normalize(sD,'range');
end

%% 3 - Map generation
size=input('Do you want to choose the map size?','s');
if strcmp(size,'Yes')==1 || strcmp(size,'yes')==1 || 
strcmp(size,'YES')==1 || strcmp(size,'y')==1
   ver=input('Define vertical dimension:');
   hor=input('Define horizontal dimension:');
   sM=som_make(sD,'msize',[ver hor]);
else
   sM=som_make(sD);
end
sM=som_autolabel(sM,sD,'freq');

%% 4 - Data visualization 
% Visualization of the map is divided into the main map, u-matrix map, u-matrix clustered and component map
figure(1)
som_show(sM,'color',{p{i},sprintf('%d clusters',i)}); % 
visualize
som_show_add('label',sM,'textsize',13)
colormap(jet(i)), som_recolorbar % change colormap

% U-matrix
figure(2)
som_show(sM,'umat','all')

% U-matrix clustered based map
figure(3)
som_show(sM,'color',{som_dmatclusters(sM),sprintf('Cluster 
U-Matrix')})
som_show_add('label',sM,'textsize',9)
colormap(jet(max(som_dmatclusters(sM))))
dim_dmat=unique(som_dmatclusters(sM).');

% Component map
figure(4)
som_show(sM,'comp','all')
%som_show(sM,’comp’,’all’,’norm’,’n’) Remove commentary if 
c-planes will be normalized.
% Empty map with labels
figure(5)
som_show(sM,'empty','Sample labels')
som_show_add('label',sM.labels,'textsize',11,'textcolor','b
')

% - 5. Quality map measurement (QE, TE)
% Values of quantification error (QE) and topographical error (TE) of the map generated are returned.
% QE should be minimized and TE, ideally, should be 0.
[QE,TE]=som_quality(sM,sD)

