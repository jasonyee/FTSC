function rdev = func_dev(nsamples, t, var)
%FUNC_DEV Generating functional deviation
%   Functional deviations follows a centered Gaussian with reproducing
%   kernel as covariance matrix
%Usage:
%   
%   rdev = func_dev(nsamples, t, variance)
%
%   nsamples: number of draws
%   t: 1-by-T time points vector
%   var: variance parameter of the centered Gaussian distribution
%   rdev: nsamples-by-T matrix of simulated functional deviations

    T = size(t,2);
    scale_mat = sqrt(var) * chol(rp_kernel(t),'lower');
    rdev = (scale_mat * randn(T,nsamples))';
end


function rp_kernel_mat = rp_kernel(t)
%RP_KERNEL Generating reproducing kernel covariance matrix
%   Reproducing kernel covariance matrix is generated from Bernoulli
%   polynomials
%Usage:
%   
%   rp_kernel_mat = rp_kernel(t)
%
%   t: 1-by-T time points vector
%   rp_kernel_mat: T-by-T reproducing kernel covariance matrix
    
    cen2 = @(x) (abs(x)-.5)^2;
    dk2 = @(x) (cen2(x)-1/12)/2;
    dk4 = @(x) (cen2(x)^2-cen2(x)/2+7/240)/24;
    rc = @(x,y) ( dk2(y) * dk2(x) - dk4(x-y) );
    
    T = size(t,2);
    rp_kernel_mat = zeros(T);
    for i=1:T
        for j=1:T
            rp_kernel_mat(i,j) = rc(t(i),t(j));
        end
    end
end
