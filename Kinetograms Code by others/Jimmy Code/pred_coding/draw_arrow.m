%x,y = position
%col = color
%dir = direction (2=left,1=right)
function draw_arrow(x,y,col,dir)

line_width=50;
line_thickness=10;

arrow_width=line_width/2;
arrow_height=line_width/2;

cgpencol(col);
cgrect(x,y,line_width,line_thickness);

if dir==2
    cgpolygon([-line_width/2,-line_width/2,-(line_width/2+arrow_width)],[arrow_height/2,-arrow_height/2,0]);
else
    cgpolygon([line_width/2,line_width/2,(line_width/2+arrow_width)],[arrow_height/2,-arrow_height/2,0]);
end