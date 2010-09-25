//
//  TWGeometry.h
//
//  Copyright 2010 Trollwerks Inc. All rights reserved.
//

#define TWDEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0f * (CGFloat)M_PI)

// avoid float comparison warning ...alex
//<http://dlc.sun.com/pdf/800-7895/800-7895.pdf>
//<http://docs.sun.com/source/806-3568/ncg_goldberg.html>
#define twDefaultFloatComparisonEpsilon	0.0001
#define twEqualFloats(f1, f2)	( fabs( (f1) - (f2) ) < twDefaultFloatComparisonEpsilon )
#define twEqualFloatsEpsilon(f1, f2, epsilon)	( fabs( (f1) - (f2) ) < epsilon )
#define twNotEqualFloats(f1, f2)	( !twEqualFloats(f1, f2) )
#define twNotEqualFloatsEpsilon(f1, f2, epsilon)	( !twEqualFloatsEpsilon(f1, f2, epsilon) )
