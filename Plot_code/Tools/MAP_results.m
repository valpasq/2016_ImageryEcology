% This is the classification algorithm for classifying all map pixels by lines
%function Map=MAP_results(dir_l,n_rst,n_rec,nrow,model,num_c,nbands)
%% Constants:
% number of coefficients
% num_c=4;
% number of bands
% nbands=8;

savedir='/projectnb/landsat/projects/IDS/working/test/';

rowrange=1950:2000;
colrange=4375:4475;

for b=1:3
for nrow = rowrange
fprintf('Processing the %d row\n',nrow);

% load row
load(['/projectnb/landsat/projects/IDS/working/test/results_row',num2str(nrow),'.mat']);

    % loop over columns
    for ncol = colrange
 
        intercept=[results(ncol).intercept];
        slope=[results(ncol).slope];
        lambda=[results(ncol).lambda];
        rmse=[results(ncol).rmse];
        amplitude1=results(ncol).amplitudes(1,:);
        june=results(ncol).monthly_means(6,:);
        feb=results(ncol).monthly_means(2,:);
        jun_c=results(ncol).monthly_count(6);
        feb_c=results(ncol).monthly_count(2);
        
        may=results(ncol).monthly_means(5,:);
        may_c=results(ncol).monthly_count(5);
        oct=results(ncol).monthly_means(10,:);
        oct_c=results(ncol).monthly_count(10);
        
        amplitude2=results(ncol).amplitudes(2,:);
        amplitude3=results(ncol).amplitudes(3,:);
        

        Map1(nrow,ncol)=intercept(b);
        Map2(nrow,ncol)=slope(b);
        Map3(nrow,ncol)=lambda(b);
        Map4(nrow,ncol)=rmse(b);
        Map5(nrow,ncol)=amplitude1(1,b);
        Map6(nrow,ncol)=june(1,b);
        Map7(nrow,ncol)=feb(1,b);
        Map8(nrow,ncol)=jun_c(1);
        Map9(nrow,ncol)=feb_c(1);
        
        Map10(nrow,ncol)=may(1,b);
        Map11(nrow,ncol)=may_c(1);
        Map12(nrow,ncol)=oct(1,b);
        Map13(nrow,ncol)=oct_c(1);
        
        Map14(nrow,ncol)=amplitude2(1,b);
        Map15(nrow,ncol)=amplitude3(1,b);        
        
        
        %write TSFitMapMat.mat
        % background name for identification of row (0~9999)
        %id_name='0000';
        % str number for identification of row
        %str_num=num2str(nrow);
        % add str number to background
        %id_name((end-length(str_num)+1):end)=str_num;
        %save(['/projectnb/landsat/projects/IDS/working/test/MapMat',id_name],'Map');
    end
end

cd(savedir)

M1g=mat2gray(Map1(rowrange,colrange));
imwrite(M1g,['map1_',num2str(b),'.png'])

M2g=mat2gray(Map2(rowrange,colrange));
imwrite(M2g,['map2_',num2str(b),'.png'])

M3g=mat2gray(Map3(rowrange,colrange));
imwrite(M3g,['map3_',num2str(b),'.png'])

M4g=mat2gray(Map4(rowrange,colrange));
imwrite(M4g,['map4_',num2str(b),'.png'])

M5g=mat2gray(Map5(rowrange,colrange));
imwrite(M5g,['map5_',num2str(b),'.png'])

M6g=mat2gray(Map6(rowrange,colrange));
imwrite(M6g,['map6_',num2str(b),'.png'])

M7g=mat2gray(Map7(rowrange,colrange));
imwrite(M7g,['map7_',num2str(b),'.png'])

M8g=mat2gray(Map8(rowrange,colrange));
imwrite(M8g,['map8_',num2str(b),'.png'])

M9g=mat2gray(Map9(rowrange,colrange));
imwrite(M9g,['map9_',num2str(b),'.png'])

M10g=mat2gray(Map10(rowrange,colrange));
imwrite(M10g,['map10_',num2str(b),'.png'])

M11g=mat2gray(Map11(rowrange,colrange));
imwrite(M11g,['map11_',num2str(b),'.png'])

M12g=mat2gray(Map12(rowrange,colrange));
imwrite(M12g,['map12_',num2str(b),'.png'])

M13g=mat2gray(Map13(rowrange,colrange));
imwrite(M13g,['map13_',num2str(b),'.png'])

M14g=mat2gray(Map14(rowrange,colrange));
imwrite(M14g,['map14_',num2str(b),'.png'])

M15g=mat2gray(Map15(rowrange,colrange));
imwrite(M15g,['map15_',num2str(b),'.png'])


multi1=cat(3, M1g, M5g, M4g);  % R=intercept, G=Amplitude, B=RMSE
imwrite(multi1,['mapIntAmpRMSE_',num2str(b),'.png'])

multi2=cat(3,  M1g, M6g, M7g);
imwrite(multi2,['mapIntJunDec_',num2str(b),'.png'])

multi3=cat(3,  M3g, M5g, M4g);
imwrite(multi3,['mapLambdaAmpRMSE_',num2str(b),'.png'])

multi4=cat(3, M1g, M10g, M12g);
imwrite(multi4,['IntMayOct_',num2str(b),'.png'])

multi5=cat(3, M11g, M8g, M9g);
imwrite(multi5,['MayJunFebCount_',num2str(b),'.png'])

multi6=cat(3, M1g, M14g, M15g);
imwrite(multi6,['Int6m4m_',num2str(b),'.png'])

fclose all 

end

