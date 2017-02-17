function output=PA_Model(x,b,K, Q)
%PA MODEL, order K=11, M=1
%--------------------------------------------
%       Tomas GOTTHANS, Roman MARSALEK 2015
%       gotthans@feec.vutbr.cz, marsaler@feec.vutbr.cz
%--------------------------------------------



 output=zeros(1,length(x));

 fi=zeros(K,K);
    
   for k=1:K % on page 1473
        for l=1:k
                   fi(l,k)=fi(l,k)+(((-1)^(l+k))*(factorial(k+l)/(factorial(l-1)*factorial(l+1)*factorial(k-l))));
          
         
        end;
        
    end;
 
psi_2=zeros(length(x),K*(Q+1)); 

x=transpose(x);
for k=1:K 
            
    for q=0:Q 
           
        x22=vertorshft2(x,-q);
            x22=(x22); 
       for l=1:k
                psi_2(:,k+(q*K))=psi_2(:,k+(q*K))+(fi(l,k).*((abs(x22).^(l-1)).*x22));  
       end;
       
       output=output+(b(k+(q*K),1).*transpose(psi_2(:,k+(q*K))));
    end;
    
end

if(0)
%CLIPPING
  for i=1:length(output)
        if (abs(output(i))>1.0)
            output(i)=1.0*exp(j*angle(output(i)));
        end;
  end;
end


function [out]=vertorshft2(in,q)
%q=-q;
out=zeros(length(in),1);

if (q>0)
  out(1:end-q)=in(q+1:end);  
end;

if (q<0)
   
out(((-q)+1):end)=in(1:(end-(abs(q))));
end;


if (q==0)
    out=(in);
end;