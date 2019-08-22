% -------------Software Disclaimer---------------
%
% NIST-developed software is provided by NIST as a public service. You may use, copy
% and distribute copies of the software in any medium, provided that you keep intact this
% entire notice. You may improve, modify and create derivative works of the software or
% any portion of the software, and you may copy and distribute such modifications or
% works. Modified works should carry a notice stating that you changed the software
% and should note the date and nature of any such change. Please explicitly
% acknowledge the National Institute of Standards and Technology as the source of the
% software.
%
% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY
% OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
% WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
% NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS
% NOR WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE
% UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE
% CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS
% REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF,
% INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY,
% RELIABILITY, OR USEFULNESS OF THE SOFTWARE.
%
% You are solely responsible for determining the appropriateness of using
% anddistributing the software and you assume all risks associated with its use, including
% but not limited to the risks and costs of program errors, compliance with applicable
% laws, damage to or loss of data, programs or equipment, and the unavailability or
% interruption of operation. This software is not intended to be used in any situation
% where a failure could cause risk of injury or damage to property. The software
% developed by NIST employees is not subject to copyright protection within the United
% States.


% verifypathTreeTraversal is used to check whether two planes are facing
%each other or whether the the point and the plane (normal) are on the same side.

% For two planes to be facing each other the dot product between one plane's
% normal and the difference vector between a pair of points on either plane
% should be less than or equal to zero. A corner case arises when two
% triangles have a cammon side. the difference vector can be zero in such a
% case. to get around this case we take the difference between three
% distinct pairs and check for dotproduct.

%For a plane and a point to be on same side. We populate the vertices input
%with three copies of the point coordinates. Normal of the plane doesnt
%matter. The function will perform all the above steps for two planes while
%avoiding the reciprocal case.

%Inputs:
%Point11, Point12, Point13 - vertices of triangle 1
%Point21, Point22, Point23 - vertices of triangle 2
%Normal1 - normal of the plane of triangle 1
%Normal2 - normal of the plane of triangle 2
%Plane1 - plane equation of triangle 1
%Plane2 - plane equation of triangle 2
% condition1 - -1 to verify path between Tx and plane
%               0 to verify path between two planes
%               1 to verify path between plane and Rx

%Outputs:
%switch3 - boolean which holds the information of possibility of path

function [switch3]=verifypathTreeTraversal(Point11,Point12,Point13,...
    Point21,Point22,Point23,Normal1,Normal2,Plane1,Plane2,condition1)
vector1121=Point11-Point21;
vector2111=Point21-Point11;
vector1222=Point12-Point22;
vector2212=Point22-Point12;
vector1323=Point13-Point23;
vector2313=Point23-Point13;
switch3=1;

switch3=switch3 && (dot(vector1121,Normal1)<=0);

switch3=switch3 && (dot(vector1222,Normal1)<=0);

switch3=switch3 && (dot(vector1323,Normal1)<=0);

switch3=switch3 && ((distanceOfPointFromPlane(Point21, Plane1)~=0) ||...
    (distanceOfPointFromPlane(Point22, Plane1)~=0) ||...
    (distanceOfPointFromPlane(Point23, Plane1)~=0));


if(condition1==0)
    switch3=switch3 && (dot(vector2111,Normal2)<=0);
    switch3=switch3 && (dot(vector2212,Normal2)<=0);
    switch3=switch3 && (dot(vector2313,Normal2)<=0);
    switch3=switch3 && ((distanceOfPointFromPlane(Point11, Plane2)~=0) ||...
        (distanceOfPointFromPlane(Point12, Plane2)~=0) ||...
        (distanceOfPointFromPlane(Point13, Plane2)~=0));
    
end

% % Uncomment this part of code when using environment that is not a box.
% switch3 = 1;

end