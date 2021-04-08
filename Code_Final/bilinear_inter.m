function [val] = bilinear_inter(Q, P, x, y)
    A = double([Q(1), Q(2); Q(3), Q(4)]);
    X = [P(2) - x, x - P(1)];
    Y = [P(4) - y; y - P(3)];
    val = (X * A * Y) ./ ((P(2)-P(1))*(P(4)-P(3)));
end

