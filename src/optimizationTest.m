rows = 100;
columns = 100;

mat1=random('unif',0, 100, rows, columns);
mat2=random('unif',0, 100, rows, columns);

nnmfFn_Div(mat1, mat2, 100);

nnmfFn_Div_v2(mat1, mat2, 100);