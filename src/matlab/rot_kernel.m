function [Y] = rot_kernel(kernel, deg)

N = size( kernel, 1 );
max_rots = 4*(N-1);
deg_per_rot = 360 / max_rots;

% deg = deg - mod( deg, deg_per_rot );
deg = deg_per_rot * ( round( deg / deg_per_rot ) );
num_of_rots = ceil( deg / deg_per_rot );

if num_of_rots < 1
    Y = kernel;
    return
else
    for r = 1:num_of_rots
        if mod( r, 2 ) == 0
            kernel = rot_outer_layer( kernel );
        else
            kernel = rot_inner_layer( kernel );
        end
    end
end

Y = kernel;

end

function [Y] = rot_outer_layer( A ) 
    dim = size( A, 1 );
    top = A( 1, : );
    right = A( 2:dim, dim )';
    bottom = fliplr( A( dim, 1:dim - 1 ) );
    left = fliplr( A( 2:dim - 1, 1 )' );
    shifted_layers = wshift('1D',[top,right,bottom,left],-1);
    
    top = shifted_layers( 1:length(top));
    last_ind = length( top );
    
    right = shifted_layers( last_ind + 1 : last_ind + length(right));
    last_ind = last_ind + length( right );
    
    bottom = shifted_layers( last_ind + 1 : last_ind + length(bottom));
    last_ind = last_ind + length( bottom );
    
    left = shifted_layers( last_ind + 1 : end );
    
    A( 1, : ) = top;
    A( 2:dim, dim ) = right';
    A( dim, 1:dim - 1 ) = fliplr( bottom );
    A( 2:dim - 1, 1 ) = fliplr( left' );
    
    Y = A;
end

function [Y] = rot_inner_layer( kernel )
%     dim = size( kernel, 1 );
%     if  dim < 2
%         Y = rot_outer_layer( kernel )
%         return;
%     else
%         Y = rot_inner_layer( kernel( 2:dim - 1, 2:dim - 1 ) )
%     end
    dim = size( kernel, 1 );
    
    if mod( dim / 2, 2 ) == 0
        max_rots = dim / 2 - 1;
    else
        max_rots = dim / 2 - 0.5;
    end
    
    low = 2;
    high = dim - 1;
    for i = 1:max_rots
        kernel( low:high, low:high ) = rot_outer_layer( kernel( low:high, low:high ) );
        low = low + 1;
        high = high - 1;
    end
    
    Y = kernel;
end