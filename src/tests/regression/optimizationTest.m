addpath(srcPath)
addpath(assetsPath)
%%
% TODO: Add test folder; clean out script files; add assets folder for
% non-code files
%%General Optimization Comparions
clear all
clc

K = 100; %Kept constant (Rows of source and target); 8193 in real application
M = 80; %Variable (Columns of target)
N = 80; %Variable (Columns of source)
iterations = 50;

mat1=random('unif',0, 100, K, M);
mat2=random('unif',0, 100, K, N);
mat2=mat1; %For diagonality check

TSTART_DIV_OPT = tic;
[factor1 cost]=KLDiv_opt_TEST(mat1, mat2, iterations, 'diag');
TEND_DIV_OPT = toc(TSTART_DIV_OPT);

TSTART_DIV_UNOPT = tic;
[factor2 cost2]=KLDiv_unopt_TEST(mat1, mat2, iterations, 'diag');
TEND_DIV_UNOPT = toc(TSTART_DIV_UNOPT);

TSTART_EUCL = tic;
[factor3 cost3]=nnmfFn_Eucl_TEST(mat1, mat2, iterations, 'diag');
TEND_EUCL = toc(TSTART_EUCL);

TSTART_DIV_OPT_ND = tic;
[factor4 cost4]=KLDiv_opt_TEST(mat1, mat2, iterations, 'no_diag');
TEND_DIV_OPT_ND = toc(TSTART_DIV_OPT_ND);

TSTART_DIV_UNOPT_ND = tic;
[factor5 cost5]=KLDiv_unopt_TEST(mat1, mat2, iterations, 'no_diag');
TEND_DIV_UNOPT_ND = toc(TSTART_DIV_UNOPT_ND);

TSTART_EUCL_ND = tic;
[factor6 cost6]=nnmfFn_Eucl_TEST(mat1, mat2, iterations, 'no_diag');
TEND_EUCL_ND = toc(TSTART_EUCL_ND);

subplot(321)
plot(cost)
title('Kullback-Leibler Divergence (Optimized)')
subplot(322)
plot(cost4)
title('Kullback-Leibler Divergence No Diagonals (Optimized)')
subplot(323)
plot(cost2)
title('Kullback-Leibler Divergence (Unoptimized)')
subplot(324)
plot(cost5)
title('Kullback-Leibler Divergence No Diagonals (Unoptimized)')
subplot(325)
plot(cost3)
title('Euclidean')
subplot(326)
plot(cost6)
title('Euclidean No Diagonals')

figure()
bar([TEND_DIV_OPT TEND_DIV_OPT_ND; TEND_DIV_UNOPT TEND_DIV_UNOPT_ND; TEND_EUCL TEND_EUCL_ND])
set(gca,'XTickLabel',{'Divergence (Optimized)', 'Divergence (Unoptimized)', 'Euclidean'})
legend('Diagonals', 'No Diagonals');

figure()
subplot(321)
imagesc(factor1)
title('Kullback-Leibler Divergence (Optimized)')
subplot(322)
imagesc(factor2)
title('Kullback-Leibler Divergence (Unoptimized)')
subplot(323)
imagesc(factor3)
title('Euclidean')
subplot(324)
imagesc(factor4)
title('Kullback-Leibler Divergence No Diagonals (Optimized)')
subplot(325)
imagesc(factor5)
title('Kullback-Leibler Divergence No Diagonals (Unoptimized)')
subplot(326)
imagesc(factor6)
title('Euclidean No Diagonals')
%% Optimized Divergence (No Diagonals) Algorithm Scaling
sizes = [10, 25, 50, 75, 100, 150, 200];
rows = 100; %Kept constant (Rows of source and target); 8193 in real application
iterations = 50;
j = 1;
% parfor i = sizes
for i = sizes
    columns = i;

    mat1=random('unif',0, 100, rows, columns);
    mat2=random('unif',0, 100, rows, columns);
%     mat2=mat1; %For diagonality check
    
    TSTART_OPT_DIV_ND = tic;
    [factor cost]=KLDiv_opt_TEST(mat1, mat2, iterations, 'no_diag');
    TEND_OPT_DIV_ND(j) = toc(TSTART_OPT_DIV_ND);
    j = j+1;
end

plot(sizes, TEND_OPT_DIV_ND);
xlabel('Template Number')
ylabel('Time (s)')
%% Unoptimized Divergence (No Diagonals) Algorithm Scaling
sizes = [10, 25, 50, 75, 100, 150];
rows = 100; %Kept constant (Rows of source and target); 8193 in real application
iterations = 50;
j = 1;
% parfor i = sizes
for i = sizes
    columns = i;

    mat1=random('unif',0, 100, rows, columns);
    mat2=random('unif',0, 100, rows, columns);
%     mat2=mat1; %For diagonality check
    
    TSTART_UNOPT_DIV_ND = tic;
    [factor cost]=KLDiv_unopt_TEST(mat1, mat2, iterations, 'no_diag');
    TEND_UNOPT_DIV_ND(j) = toc(TSTART_UNOPT_DIV_ND);
    j = j+1;
end

plot(sizes, TEND_UNOPT_DIV_ND);
xlabel('Template Number')
ylabel('Time (s)')
%% Euclidean Algorithm Scaling
sizes = [10, 25, 50, 75, 100, 150, 200, 400, 1000, 2000];
rows = 100; %Kept constant (Rows of source and target); 8193 in real application
iterations = 50;
j = 1;
% parfor i = sizes
for i = sizes
    columns = i;

    mat1=random('unif',0, 100, rows, columns);
    mat2=random('unif',0, 100, rows, columns);
%     mat2=mat1; %For diagonality check
    
    TSTART_EUCL_ND = tic;
    [factor cost]=nnmfFn_Eucl_TEST(mat1, mat2, iterations, 'no_diag');
    TEND_EUCL_ND(j) = toc(TSTART_EUCL_ND);
    j = j+1;
end

plot(sizes, TEND_EUCL_ND);
xlabel('Template Number')
ylabel('Time (s)')
%% Plot Algo Scaling Tests
% Note: Only run after previous three sections have been run
figure()
plot([10, 25, 50, 75, 100, 150, 200], TEND_OPT_DIV_ND);
hold on
plot([10, 25, 50, 75, 100, 150], TEND_UNOPT_DIV_ND);
hold on
plot([10, 25, 50, 75, 100, 150, 200, 400, 1000, 2000], TEND_EUCL_ND);
xlabel('Template Number')
ylabel('Time (s)')
legend('Optimized Divergence', 'Unoptimized Divergence', 'Euclidean')
title('Algorithm Scaling Comparison')
%% Sparse Matrix Multiplication Test
