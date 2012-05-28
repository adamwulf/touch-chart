# TOUCH CHART V0.1
In line with Sylion's work philosophy the design has been developed to greatly simplify the complexity of the code and maximizing the recycling of classes, as well as providing great ways for their extension.
- Angles between adjacent points.
- Direction changes between points close in the list.

If we analyze the geometry of the square, rhombus and circle we notice that the relative position of maximums and minimums in the XY coordinate axis are different. The rhombus and circle contain their maximums in the middle point of the imaginary square that covers them, while the square has its maximums and minimums in each of its vertex. This feature is therefore very useful when we try to distinguish squares from circles or rhombus.

The controller also calculates the existing angles between a sequence of points in a path. If the angle in a three point sequence is around 180° it is known that the user is tracing a straight line. If by contrast these angles are inferior to an approximate value of 140° you can infer that the user is drastically changing the direction in the trace. This feature shows in a useful way the number of resulting vertices the figure could have.
## DIRECTION CHANGES
Just as we did with the angles `SYGeometricMathController` analyzes the point list and infers how they vary in the XY positions for each point regarding the previous. This reveals abrupt direction changes. Either the square or rhombus show abrupt direction changes while, in a properly traced circle, direction changes are gentle and progressive.

The following values have been empirically obtained with successive trials in drawings by different users. It's known that for angle variations of zero or close to zero the figure has a high probability of being a circle. On the other hand, for changes in direction superior to eight it could be said with high probability that the figure to be drawn is a rhombus. For angle and direction values between two and five figure identification becomes less accurate or with an inferior chance of success.