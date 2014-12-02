//
//  YYHMantleModelSerializer.m
//  YYHModelRouterExample
//
//  Created by Angelo Di Paolo on 11/28/14.
//  Copyright (c) 2014 Yayuhh. All rights reserved.
//

#import "YYHMantleModelSerializer.h"

#import <Mantle/Mantle.h>

@implementation YYHMantleModelSerializer

#pragma mark - YYHModelSerialization

- (id)modelForJSONDictionary:(NSDictionary *)jsonDictionary modelClass:(Class)modelClass error:(NSError *__autoreleasing *)error {
    return [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:jsonDictionary error:error];
}

- (id)modelsForJSONArray:(NSArray *)jsonArray modelClass:(Class)modelClass error:(NSError *__autoreleasing *)error {
    return [MTLJSONAdapter modelsOfClass:modelClass fromJSONArray:jsonArray error:error];
}

@end
