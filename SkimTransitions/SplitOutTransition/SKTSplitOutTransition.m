//
//  SKTSplitOutTransition.m
//  SkimTransitions
//
//  Created by Christiaan Hofman on 22/5/2019.
//  Copyright Christiaan Hofman 2019. All rights reserved.
//

#import "SKTSplitOutTransition.h"
#import "SKTPluginLoader.h"

@implementation SKTSplitOutTransition

@synthesize inputImage, inputTargetImage, inputCenter, inputExtent, inputTime;

static CIKernel *_SKTSplitOutTransitionKernel = nil;

- (id)init
{
    if (_SKTSplitOutTransitionKernel == nil)
        _SKTSplitOutTransitionKernel = [SKTPlugInLoader kernelWithName:@"boxComposition"];
    return [super init];
}

+ (NSDictionary *)customAttributes
{
    return [NSDictionary dictionaryWithObjectsAndKeys:

        [NSDictionary dictionaryWithObjectsAndKeys:
            [CIVector vectorWithX:150.0 Y:150.0], kCIAttributeDefault,
            kCIAttributeTypePosition,          kCIAttributeType,
            nil],                              kCIInputCenterKey,
 
        [NSDictionary dictionaryWithObjectsAndKeys:
            [CIVector vectorWithX:0.0 Y:0.0 Z:300.0 W:300.0], kCIAttributeDefault,
            kCIAttributeTypeRectangle,          kCIAttributeType,
            nil],                               kCIInputExtentKey,
 
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble:  0.0], kCIAttributeMin,
            [NSNumber numberWithDouble:  1.0], kCIAttributeMax,
            [NSNumber numberWithDouble:  0.0], kCIAttributeSliderMin,
            [NSNumber numberWithDouble:  1.0], kCIAttributeSliderMax,
            [NSNumber numberWithDouble:  0.0], kCIAttributeDefault,
            [NSNumber numberWithDouble:  0.0], kCIAttributeIdentity,
            kCIAttributeTypeTime,              kCIAttributeType,
            nil],                              kCIInputTimeKey,

        nil];
}

- (NSDictionary *)customAttributes
{
    return [[self class] customAttributes];
}

// called when setting up for fragment program and also calls fragment program
- (CIImage *)outputImage
{
    CISampler *src = [CISampler samplerWithImage:inputImage];
    CISampler *trgt = [CISampler samplerWithImage:inputTargetImage];
    CGFloat x = [inputExtent X];
    CGFloat y = [inputExtent Y];
    CGFloat width = [inputExtent Z];
    CGFloat height = [inputExtent W];
    CGFloat cx = [inputCenter X];
    CGFloat t = [inputTime doubleValue];
    CIVector *rect = [CIVector vectorWithX:(1.0 - t) * cx + t * x Y:y Z:t * width W:height];
    NSArray *extent = [NSArray arrayWithObjects:[NSNumber numberWithDouble:x], [NSNumber numberWithDouble:y], [NSNumber numberWithDouble:width], [NSNumber numberWithDouble:height], nil];
    NSArray *arguments = [NSArray arrayWithObjects:trgt, src, rect, nil];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:extent, kCIApplyOptionDefinition, extent, kCIApplyOptionExtent, nil];
    
    return [self apply:_SKTSplitOutTransitionKernel arguments:arguments options:options];
}

@end
