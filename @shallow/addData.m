function addData(obj,inputdir)

tmppath=pwd;

if nargin==1 % no directory provided
    disp('Input data directory:');
    pathe = uigetdir(tmppath,'Select directory with data:');
    
    if pathe==0
        disp('Quit!');
        return;
    end
else
    pathe=inputdir;
end

% parse input folder:
newdata=parseInputData(pathe);

% update fovs in project: 


 nfov=numel(obj.fov);
 if nfov==1 & numel(obj.fov.srclist)==0
     cc=1;
 else
     cc=nfov+1;
 end
 
for i=1:numel(newdata.pos) % loop on all the fov / positions / folders to be created:::parfor useless, waste of time to launch the pool

    obj.fov(cc)=fov;
    
    obj.fov(cc).setpathlist(newdata.pos(i).pathlist,cc,newdata.pos(i).filelist,newdata.pos(i).name);

    obj.fov(cc).display.binning=newdata.pos(i).binning;
    obj.fov(cc).display.intensity=ones(1,size(newdata.pos(i).binning,2));
    obj.fov(cc).channel=newdata.pos(i).channelname;
    obj.fov(cc).frames=newdata.pos(i).frames;
      cc=cc+1;
end

disp([num2str(numel(newdata.pos)) ' FOVs were added to the current project!']);

