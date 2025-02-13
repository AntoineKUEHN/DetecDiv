function output=formatObjectTrainingSet(foldername,classif,rois)

output=0;
        if ~isfolder([classif.path '/' foldername '/images'])
            mkdir([classif.path '/' foldername], 'images');
        end

        for i=1:numel(classif.classes)
            if ~isfolder([classif.path '/' foldername '/images/' classif.classes{i}])
                mkdir([classif.path '/' foldername '/images'], classif.classes{i});
            end
        end
        
        cltmp=classif.roi; 

disp('Starting parallelized jobs for data formatting....')

warning off all
 channel=classif.channelName;
 
parfor i=rois
    disp(['Launching ROI ' num2str(i) :' processing...'])
    
    
    if numel(cltmp(i).image)==0
        cltmp(i).load; % load image sequence
    end
    
  
    % normalize intensity levels
       
    pix=cltmp(i).findChannelID(channel);

    if iscell(pix)
            pix=cell2mat(pix);
    end
    
    %pix=find(cltmp(i).channelid==classif.channel(1)); % find channel
    im=cltmp(i).image(:,:,pix,:);
    
    if numel(pix)==1
        % 'ok'
        totphc=im;
        meanphc=0.5*double(mean(totphc(:)));
        maxphc=double(meanphc+0.7*(max(totphc(:))-meanphc));
    end
    
   
    
  
    
    reverseStr = '';
    
    
    pixelchannel2=cltmp(i).findChannelID(classif.strid);
    pix2=find(cltmp(i).channelid==pixelchannel2);
                
    % find channel associated with user classified objects
    im2=cltmp(i).image(:,:,pix2,:);

    
    
    for j=1:size(im,4)
        tmp=im(:,:,:,j);
        
        if numel(pix)==1
            
            tmp = double(imadjust(tmp,[meanphc/65535 maxphc/65535],[0 1]))/65535;
            tmp=repmat(tmp,[1 1 3]);
            
            
            %max(tmp(:))
            %return
        end
        
        
        
        tr=num2str(j);
        while numel(tr)<4
            tr=['0' tr];
        end
        
        
        
  
            %if cltmp(i).train.(classif.strid).id(j)~=0 % if training is done
                % if ~isfile([str '/unbudded/im_' mov.trap(i).id '_frame_' tr '.tif'])
                %make a loop on all objects of each image
                labeledobjects=im2(:,:,:,j);
                
                if max(labeledobjects(:))==0 % image is not annotated
                    continue
                end
                
               
                [l no]=bwlabel(labeledobjects>0);
                 pr=regionprops(l,'BoundingBox');
                
                for k=1:no % loop on all present objects
                    
                    bw=l==k;
                    
                  %  if j==16
                    bbox=round(pr(k).BoundingBox);
                    clas=round(mean(labeledobjects(bw)));
                    
                    imcrop=tmp(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:);
                    
                   % figure, imshow(imcrop,[]);
                   % figure, imshow(tmp,[]);
                     imwrite(imcrop,[classif.path '/' foldername '/images/' classif.classes{clas} '/' cltmp(i).id '_frame_' tr '_obj' num2str(k) '.tif']);
                      output=output+1;
                %    end
                    
                    
                end
                
                 % end
            %end
     
       msg = sprintf('Processing frame: %d / %d for ROI %s', j, size(im,4),cltmp(i).id); %Don't forget this semicolon
       fprintf([reverseStr, msg]);
       reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
    
    fprintf('\n');

    cltmp(i).save;

    disp(['Processing ROI: ' num2str(i) ' ... Done !'])
end

warning on all;

for i=rois
    cltmp(i).clear; %%% remove !!!!
end


end

