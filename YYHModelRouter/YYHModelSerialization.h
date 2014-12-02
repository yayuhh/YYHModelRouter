//
//  YYHModelSerialization.h
//  Ampersand
//
//  Created by Angelo Di Paolo on 11/26/14.
//  Copyright (c) 2014 Yayuhh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YYHModelSerialization <NSObject>

- (id)modelsForJSONArray:(NSArray *)jsonArray modelClass:(Class)modelClass error:(NSError **)error;
- (id)modelForJSONDictionary:(NSDictionary *)jsonDictionary modelClass:(Class)modelClass error:(NSError **)error;

@end
