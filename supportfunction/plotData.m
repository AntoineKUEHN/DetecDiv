function plotData(datagroups,filename,varargin)
% plot dataseries from rois as a collection of single cell traj and/or
% averages

% for single cells , one plot per datagroup and per datatype (mean, max 20
% pixels)

% for averages, put all datagroups on one plot to compare the datagroups,
% provide averag, standard deviation and bootstrap for standard error on
% mean

% special plot for RLS data : event / div duration : ecf function : plot
% reletaed to the number of events in array

[p ,f ,ext]=fileparts(filename);

for i=1:numel(datagroups)

    if ~isfield(datagroups(i).Source,'nodename') % user did not check any node, so skip plotting
        continue
    end

    dat=datagroups(i).Source.nodename;

    rois=datagroups(i).Data.roiobj;

    for j=1:numel(dat) % loop on plotted data types
        str=[datagroups(i).Name ' // ' dat{j}{1} ' // ' dat{j}{2}];

        d=dat{j};

        %strtot={};
        %cc=1;
        hold on;

        cmap=lines(numel(rois));
        cmapcell = mat2cell(cmap, ones(numel(rois),1), 3);

        xout={};
        yout={};

        for k=1:numel(rois)

            groups={rois(k).data.groupid};
            pix=find(matches(groups,d{1}));

            if numel(pix)

                yout{end+1}= rois(k).data(pix).getData(d{2});

                xout{end+1}=1:numel(yout);

                if strcmp(datagroups(i).Param.Plot_type{end},'generation')
                    switch datagroups(i).Param.Traj_synchronization{end}
                        case 'sep'
                            xout{end}= rois(k).data(pix).getData('sep');
                        case 'death'
                            xout{end}= rois(k).data(pix).getData('death');
                        otherwise % birth
                            xout{end}= rois(k).data(pix).getData('birth');
                    end
                end



            end
        end

        if datagroups(i).Param.Plot_singletraj
            h(i,j)=figure('Color','w','Tag',['plot_singletraj' num2str(i) '_' num2str(j)],'Name',str);

            hold on;
            cellfun(@(x, y, c) plot(x, y, 'Color',c), xout, yout, cmapcell', 'UniformOutput', false); 

            if strcmp(datagroups(i).Param.Plot_type{end},'temporal')
                xlabel('Time (frames)');
            end
            if strcmp(datagroups(i).Param.Plot_type{end},'generation')
                xlabel('Generation');
            end

            ylabel(dat{j}{2},'Interpreter','None');
        end

        if datagroups(i).Param.Plot_average
            g(i,j)=figure('Color','w','Tag',['plot_' num2str(i) '_' num2str(j)],'Name',str);
   
            yout=cellfun(@(x,y) y(~isnan(x)), xout,yout,'UniformOutput',false);
            xout=cellfun(@(x) x(~isnan(x)), xout,'UniformOutput',false);

            valMin = cellfun(@(x) min(x), xout); totMin=min(valMin);
            valMax = cellfun(@(x) max(x), xout);
            totMax=max(valMax)+1;
            totMax= num2cell(totMax*ones(1,numel(valMax)));
            len=cellfun(@(x) length(x), xout,'UniformOutput',false);
            valMax = cellfun(@(x,y) x-y,  totMax,len,'UniformOutput',false);

            paddedx=cellfun(@(x,y) padarray(x, [y 0],NaN,'post'),xout,valMax,'UniformOutput',false);
            paddedy=cellfun(@(x,y) padarray(x, [y 0],NaN,'post'),yout,valMax,'UniformOutput',false);

            listx=cell2mat(paddedx);
            listy=cell2mat(paddedy);

            meanx=min(listx(:)):max(listx(:));
            meany=mean(listy,2,'omitnan');
            stdy = std(listy,2,'omitnan');


        

        end


    end



end

return;



for i=1:numel(dat)
    if numel(dat)>0

        d=dat{i};

        outfile=fullfile(p,[f '_' d{1} '.xlsx']); %write as xlsx is important , otherwise throw an error with large files

        if exist(outfile)
            delete(outfile);
        end
    end
end

for i=1:numel(dat)
    if numel(dat)>0

        d=dat{i};

        strtot={};
        cc=1;
        for j=1:numel(rois)

            groups={rois(j).data.groupid};
            pix=find(matches(groups,d{1}));

            if numel(pix)
                out= rois(j).data(pix).getData(d{2});

                str={};
                str{1}=rois(j).id;

                if iscell(out)
                    str=[str out'];
                else
                    str2=num2cell(out');
                    ny=size(str2,1);
                    if ny>1
                        str(2:ny,1)={[]};
                    end

                    str=[str str2];
                end


                strtot((cc-1)*size(str,1)+1:cc*size(str,1),1:size(str,2))=str;
                cc=cc+1;

            end
        end

        if cc>1
            tt=fullfile(p,[f '_' d{1} '.xlsx']);

            writecell(strtot,fullfile(p,[f '_' d{1} '.xlsx']),'sheet',d{2},'WriteMode','overwritesheet');
        end
    end
end

disp('Export is done !')

