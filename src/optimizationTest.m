% TODO: Add test folder; clean out script files; add assets folder for
% non-code files
%%General Optimization Comparions
clear all
clc

rows = 100;
columns = 100;
iterations = 50;

mat1=random('unif',0, 100, rows, columns);
% mat2=random('unif',0, 100, rows, columns);
mat2=mat1; %For diagonality check

TSTART_DIV = tic;
[factor1 cost]=nnmfFn_Div_TEST_v2(mat1, mat2, iterations, 'diag');
TEND_DIV = toc(TSTART_DIV);

TSTART_EUCL = tic;
[factor2 cost2]=nnmfFn_Eucl_TEST(mat1, mat2, iterations, 'diag');
TEND_EUCL = toc(TSTART_EUCL);

TSTART_DIV_ND = tic;
[factor3 cost3]=nnmfFn_Div_TEST_v2(mat1, mat2, iterations, 'no_diag');
TEND_DIV_ND = toc(TSTART_DIV_ND);

TSTART_EUCL_ND = tic;
[factor4 cost4]=nnmfFn_Eucl_TEST(mat1, mat2, iterations, 'no_diag');
TEND_EUCL_ND = toc(TSTART_EUCL_ND);

subplot(411)
plot(cost)
title('Kullback-Leibler Divergence')
subplot(412)
plot(cost3)
title('Kullback-Leibler Divergence No Diagonals')
subplot(413)
plot(cost4)
title('Euclidean No Diagonals')
subplot(414)
plot(cost2)
title('Euclidean')

figure()
bar([TEND_DIV TEND_DIV_ND; TEND_EUCL TEND_EUCL_ND])
set(gca,'XTickLabel',{'Divergence', 'Euclidean'})
legend('Diagonals', 'No Diagonals');

figure()
subplot(411)
imagesc(factor1)
title('Kullback-Leibler Divergence')
subplot(412)
imagesc(factor4)
title('Euclidean No Diagonals')
subplot(413)
imagesc(factor3)
title('Kullback-Leibler Divergence No Diagonals')
subplot(414)
imagesc(factor2)
title('Euclidean')
%% Divergence (No Diagonals) Algorithm Scaling
clear all
clc

% rows = 100;
% columns = 100;
% iterations = 50;
% 
% mat1=random('unif',0, 100, rows, columns);
% % mat2=random('unif',0, 100, rows, columns);
% mat2=mat1; %For diagonality check

sizes = [10, 25, 50, 75, 100, 150, 200];
% sizes = [10, 25, 50, 75, 100, 150, 200, 400, 1000, 2000];
% sizes = [10, 25, 50, 75, 100, 150, 200, 400, 600];

j = 1;
% parfor i = sizes
for i = sizes
    rows = i;
    columns = i;
    iterations = 50;

    mat1=random('unif',0, 100, rows, columns);
    mat2=random('unif',0, 100, rows, columns);
%     mat2=mat1; %For diagonality check
    
    TSTART_DIV_ND = tic;
    [factor cost]=nnmfFn_Div_TEST_v2(mat1, mat2, iterations, 'no_diag');
%     [factor cost]=BobsDivNNMF(mat1, mat2, iterations);
    TEND_DIV_ND(j) = toc(TSTART_DIV_ND);
    j = j+1;
end

plot(sizes, TEND_DIV_ND);
xlabel('Squared Matrix Size')
ylabel('Time (s)')
%% Non-Optimized Divergence (No Diagonals) Algorithm Scaling
clear all
clc

% rows = 100;
% columns = 100;
% iterations = 50;
% 
% mat1=random('unif',0, 100, rows, columns);
% % mat2=random('unif',0, 100, rows, columns);
% mat2=mat1; %For diagonality check

sizes = [10, 25, 50, 75, 100, 150, 200];
% sizes = [10, 25, 50, 75, 100, 150, 200, 400, 600];

j = 1;
% parfor i = sizes
for i = sizes
    rows = i;
    columns = i;
    iterations = 50;

    mat1=random('unif',0, 100, rows, columns);
    mat2=random('unif',0, 100, rows, columns);
%     mat2=mat1; %For diagonality check
    
    TSTART_DIV_ND = tic;
    [factor cost]=nnmfFn_Div_TEST(mat1, mat2, iterations, 'no_diag');
    TEND_DIV_ND(j) = toc(TSTART_DIV_ND);
    j = j+1;
end

plot(sizes, TEND_DIV_ND);
xlabel('Squared Matrix Size')
ylabel('Time (s)')
%% Divergence (No Diagonals) Algorithm Scaling
clear all
clc

% rows = 100;
% columns = 100;
% iterations = 50;
% 
% mat1=random('unif',0, 100, rows, columns);
% % mat2=random('unif',0, 100, rows, columns);
% mat2=mat1; %For diagonality check

sizes = [10, 25, 50, 75, 100, 150, 200, 400, 1000, 2000];
% sizes = [10, 25, 50, 75, 100, 150, 200, 400, 600];

j = 1;
% parfor i = sizes
for i = sizes
    rows = i;
    columns = i;
    iterations = 50;

    mat1=random('unif',0, 100, rows, columns);
    mat2=random('unif',0, 100, rows, columns);
%     mat2=mat1; %For diagonality check
    
    TSTART_EUCL_ND = tic;
    [factor cost]=nnmfFn_Eucl_TEST(mat1, mat2, iterations, 'no_diag');
    TEND_EUCL_ND(j) = toc(TSTART_EUCL_ND);
    j = j+1;
end

plot(sizes, TEND_EUCL_ND);
xlabel('Squared Matrix Size')
ylabel('Time (s)')
%% Sparse Matrix Multiplication Test
clear all
clc

rows = 10;
columns = 10;
iterations = 50;

mat1=random('unif',0, 100, rows, columns);
% mat2=random('unif',0, 100, rows, columns);
mat2=mat1; %For diagonality check

TSTART_DIV = tic;
[factor1 cost]=nnmfFn_Div_TEST(mat1, mat2, iterations, 'diag');
TEND_DIV = toc(TSTART_DIV);

disp(TEND_DIV);
imagesc(factor1);