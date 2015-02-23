function [width_cm]=VisAng_to_cm(angle_in_degree,viewing_dist)

% use tand function because that uses angles (if I use tan function, need
% to multiply by pi/360 or something

width_cm = tand(angle_in_degree)*viewing_dist;