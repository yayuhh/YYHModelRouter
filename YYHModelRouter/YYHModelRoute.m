//
//  YYHModelRoute.m
//  YYHModelRouter
//
//  Created by Angelo Di Paolo on 11/25/14.
//  Copyright (c) 2014 Yayuhh. All rights reserved.
//

#import "YYHModelRoute.h"

NSString * const YYHModelRouteMethodGET = @"get";
NSString * const YYHModelRouteMethodPOST = @"post";
NSString * const YYHModelRouteMethodPUT = @"put";
NSString * const YYHModelRouteMethodDELETE = @"delete";

@implementation YYHModelRoute

#pragma mark - Public API

+ (instancetype)GETRouteWithModelClass:(Class)modelClass
                               keyPath:(NSString *)keyPath {
    return [[YYHModelRoute alloc] initWithModelClass:modelClass keyPath:keyPath requestMethod:YYHModelRouteMethodGET];
}

+ (instancetype)POSTRouteWithModelClass:(Class)modelClass
                                keyPath:(NSString *)keyPath {
    return [[YYHModelRoute alloc] initWithModelClass:modelClass keyPath:keyPath requestMethod:YYHModelRouteMethodPOST];
}

+ (instancetype)PUTRouteWithModelClass:(Class)modelClass
                               keyPath:(NSString *)keyPath {
    return [[YYHModelRoute alloc] initWithModelClass:modelClass keyPath:keyPath requestMethod:YYHModelRouteMethodPUT];
}

+ (instancetype)DELETERouteWithModelClass:(Class)modelClass
                                  keyPath:(NSString *)keyPath {
    return [[YYHModelRoute alloc] initWithModelClass:modelClass keyPath:keyPath requestMethod:YYHModelRouteMethodDELETE];
}

+ (instancetype)modelRouteWithModelClass:(Class)modelClass
                                 keyPath:(NSString *)keyPath {
    return [[YYHModelRoute alloc] initWithModelClass:modelClass keyPath:keyPath];
}

+ (instancetype)modelRouteWithModelClass:(Class)modelClass
                                 keyPath:(NSString *)keyPath
                           requestMethod:(NSString *)requestMethod {
    return [[YYHModelRoute alloc] initWithModelClass:modelClass keyPath:keyPath requestMethod:requestMethod];
}


- (instancetype)initWithModelClass:(Class)modelClass
                           keyPath:(NSString *)keyPath {
    return [self initWithModelClass:modelClass keyPath:keyPath requestMethod:nil];
}

- (instancetype)initWithModelClass:(Class)modelClass
                           keyPath:(NSString *)keyPath
                     requestMethod:(NSString *)requestMethod {
    if ((self = [super init])) {
        _modelClass = modelClass;
        _keyPath = keyPath;
        _requestMethod = requestMethod != nil ? [requestMethod lowercaseString] : [YYHModelRoute getRequestMethod];
    }
    
    return self;
}

+ (NSString *)getRequestMethod {
    return YYHModelRouteMethodGET;
}

+ (NSString *)postRequestMethod {
    return YYHModelRouteMethodPOST;
}

+ (NSString *)putRequestMethod {
    return YYHModelRouteMethodPUT;
}

+ (NSString *)deleteRequestMethod {
    return YYHModelRouteMethodDELETE;
}

@end
