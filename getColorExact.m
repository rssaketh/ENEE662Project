function [nI,snI]=getColorExact(colorIm,ntscIm, params)

n=size(ntscIm,1); m=size(ntscIm,2);
imgSize=n*m;

if ~strcmp(params.colorspace, 'HSV')
    nI(:,:,1)=ntscIm(:,:,1);
    comp_temp = nI(:,:,1);
else
    nI(:,:,3) = ntscIm(:,:,3);
    comp_temp = nI(:,:,3);
end
indsM=reshape([1:imgSize],n,m);
lblInds=find(colorIm); % find where the marks have been given

wd=1; 

len=0;
consts_len=0;
col_inds=zeros(imgSize*(2*wd+1)^2,1); %3*3 times the image size for affinity matrix
row_inds=zeros(imgSize*(2*wd+1)^2,1);
vals=zeros(imgSize*(2*wd+1)^2,1);
gvals=zeros(1,(2*wd+1)^2);  %3x3 window around a non constraint?

%%%%%%%%%%%%%%%%%%% Construct the affinity matrix %%%%%%%%%%%%%%%%%%%%%%%

for j=1:m  %All cols
   for i=1:n %All rows
      consts_len=consts_len+1;
      
      if (~colorIm(i,j))   %if not a constraint
        tlen=0;
        % Check in the neighbourhood of the current pixel
        for ii=max(1,i-wd):min(i+wd,n)
           for jj=max(1,j-wd):min(j+wd,m)
            
              if (ii~=i)|(jj~=j)
                 len=len+1; tlen=tlen+1;
                 row_inds(len)= consts_len;
                 col_inds(len)=indsM(ii,jj);
                 % Getting intensities to calculate the affinity matrix
                 gvals(tlen)=comp_temp(ii,jj); %ntscIm(ii,jj,1);
%                    gvals(tlen) = ntscIm(ii,jj,3);
              end
           end
        end
        % Intensity at current pixel
        t_val= comp_temp(i,j); %ntscIm(i,j,1);
%         t_val = ntscIm(i,j,3);
        gvals(tlen+1)=t_val;
        c_var=mean((gvals(1:tlen+1)-mean(gvals(1:tlen+1))).^2);
        csig=c_var*0.6;
        mgv=min((gvals(1:tlen)-t_val).^2);
        if (csig<(-mgv/log(0.01)))
            csig=-mgv/log(0.01);
        end
        if (csig<0.000002)
            csig=0.000002;
        end
        % Exponential weight functions
        % if intensity is closer, more weight, else less weight
        gvals(1:tlen)=exp(-(gvals(1:tlen)-t_val).^2/csig);
        % Normalized to 1
        gvals(1:tlen)=gvals(1:tlen)/sum(gvals(1:tlen));
        % Not Clear why
        vals(len-tlen+1:len) = -gvals(1:tlen);
      end

        
      len=len+1;
      row_inds(len)= consts_len;
      col_inds(len)=indsM(i,j);
      vals(len)=1; 

   end
end

%%%%%%%%%%%%%%%%% End of construction of affinity matrix %%%%%%%%%%%%%%
vals=vals(1:len);
col_inds=col_inds(1:len);
row_inds=row_inds(1:len);

%Constructing the affinity matrix.
A=sparse(row_inds,col_inds,vals,consts_len,imgSize);
b=zeros(size(A,1),1);
if ~strcmp(params.colorspace,'HSV')
    range = 2:3;
else
    range = 1:2;
end
if ~params.joint
    
    for t=range
        curIm=ntscIm(:,:,t);
        b(lblInds)=curIm(lblInds);
        new_vals=A\b;   
        nI(:,:,t)=reshape(new_vals,n,m,1);    
    end
else
    b_cum = b;
    count = 1;
    for t=range
        curIm=ntscIm(:,:,t);
        b(lblInds)=curIm(lblInds);
        b_cum(:,count) = b;      % b_new = b1 + b2
        count = count + 1;    
    end
    b_joint = b_cum(:,1) + b_cum(:,2);
    new_vals=A\b_joint;
    [x1,x2] = decompose(A,b_cum(:,1),b_cum(:,2), new_vals);
%     x1 = (x1 - min(x1))/(max(x1) - min(x1));
%     x2 = (x2 - min(x2))/(max(x2) - min(x2));
    nI(:,:,range(1))=reshape(x2,n,m,1);
    nI(:,:,range(2)) = reshape(x1, n, m, 1);
end

% for t=2:3
%     curIm=ntscIm(:,:,t);
%     b(lblInds)=curIm(lblInds);
%     new_vals=A\b;   
%     nI(:,:,t)=reshape(new_vals,n,m,1);    
% end



snI=nI;
if ~strcmp(params.colorspace,'HSV')
    nI=ntsc2rgb(nI);
else
    nI = hsv2rgb(nI);
end

