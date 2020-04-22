function plotRoom(cadData, plotNormals)
if nargin < 2
    plotNormals = false;
end

[Tri,X,Y,Z] = roomCoords2triangles(cadData(:, 1:9));
trisurf(Tri,X,Y,Z,'FaceColor',[0.9,0.9,0.9],'FaceAlpha',0.4,'EdgeColor','k')

axis equal
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')

if plotNormals
    % median points of triangles
    x0 = mean(cadData(:, 1:3:9), 2);
    y0 = mean(cadData(:, 2:3:9), 2);
    z0 = mean(cadData(:, 3:3:9), 2);
    
    hold on
    quiver3(x0, y0, z0, cadData(:, 10), cadData(:, 11), cadData(:, 12))
    hold off
end