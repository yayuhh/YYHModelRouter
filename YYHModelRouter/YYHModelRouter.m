//
//  YYHModelRouter.m
//  YYHModelRouter
//
//  Created by Angelo Di Paolo on 11/25/14.
//  Copyright (c) 2014 Yayuhh. All rights reserved.
//

#import "YYHModelRouter.h"
#import "YYHModelRoute.h"

#if defined(__has_include)
#if __has_include("Mantle.h")
#define HAS_MANTLE YES

#import "YYHMantleModelSerializer.h"
#endif
#endif

const NSInteger YYHModelRouterErrorSerialization = 1;
NSString * const YYHModelRouterErrorDomain = @"com.yayuhh.YYHModelRouterError";

@interface YYHModelRouteGroup : NSObject

@property (nonatomic, strong) YYHModelRoute *getRoute;
@property (nonatomic, strong) YYHModelRoute *postRoute;
@property (nonatomic, strong) YYHModelRoute *putRoute;
@property (nonatomic, strong) YYHModelRoute *deleteRoute;

- (YYHModelRoute *)routeForRequestMethod:(NSString *)requestMethod;

@end

@implementation YYHModelRouteGroup

- (YYHModelRoute *)routeForRequestMethod:(NSString *)requestMethod {
    if ([requestMethod isEqualToString:[YYHModelRoute getRequestMethod]]) {
        return self.getRoute;
    } else if ([requestMethod isEqualToString:[YYHModelRoute postRequestMethod]]) {
        return self.postRoute;
    } else if ([requestMethod isEqualToString:[YYHModelRoute putRequestMethod]]) {
        return self.putRoute;
    } else if ([requestMethod isEqualToString:[YYHModelRoute deleteRequestMethod]]) {
        return self.deleteRoute;
    }
    return nil;
}

@end

@interface YYHModelRouter ()

@property (nonatomic, strong, readwrite) NSURL *baseURL;
@property (nonatomic, strong, readwrite) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableDictionary *routeMap;

@end

@implementation YYHModelRouter

#pragma mark - Initialization

- (instancetype)initWithBaseURL:(NSURL *)url {
    if ((self = [super init])) {
        _baseURL = url;
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:_baseURL];
#ifdef HAS_MANTLE
        _modelSerializer = [[YYHMantleModelSerializer alloc] init];
#endif
    }
    
    return self;
}

#pragma mark - Routing Internals

- (NSMutableDictionary *)routeMap {
    if (!_routeMap) {
        _routeMap = [[NSMutableDictionary alloc] init];
    }

    return _routeMap;
}

- (YYHModelRouteGroup *)routeGroupForPathPattern:(NSString *)pathPattern {
    YYHModelRouteGroup *group = self.routeMap[pathPattern];
    
    if (!group) {
        group = [[YYHModelRouteGroup alloc] init];
        self.routeMap[pathPattern] = group;
    }
    
    return group;
}

- (YYHModelRouteGroup *)routeGroupForPath:(NSString *)path {
    for (NSString *testPathPattern in self.routeMap) {
        if ([self pathPattern:testPathPattern matchesPath:path]) {
            return self.routeMap[testPathPattern];
        }
    }
    
    return nil;
}

- (YYHModelRoute *)modelRouteForPath:(NSString *)path method:(NSString *)method {
    YYHModelRouteGroup *routeGroup = [self routeGroupForPath:path];
    return [routeGroup routeForRequestMethod:method];
}

#pragma mark - Path Matching

- (BOOL)pathPattern:(NSString *)pathPattern matchesPath:(NSString *)path {
    return [self pathComponents:[pathPattern componentsSeparatedByString:@"/"]
            matchPathComponents:[path componentsSeparatedByString:@"/"]];
}

- (BOOL)pathComponents:(NSArray *)matchingComponents matchPathComponents:(NSArray *)pathComponents {
    if (matchingComponents.count == pathComponents.count) {
        NSUInteger index = 0;
        for (NSString *testComponent in matchingComponents) {
            if (![self pathComponent:testComponent matchesPathComponent:pathComponents[index]]) {
                return NO;
            }
            index++;
        }
        return YES;
    }
    return NO;
}

- (BOOL)pathComponent:(NSString *)pathComponent matchesPathComponent:(NSString *)testComponent {
    if (![pathComponent isEqualToString:testComponent]) {
        if (![pathComponent hasPrefix:@":"] && ![testComponent hasPrefix:@":"]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Routing API

- (void)routeGET:(NSString * )pathPattern modelClass:(Class)modelClass keyPath:(NSString *)keyPath {
    [self routeGroupForPathPattern:pathPattern].getRoute = [YYHModelRoute GETRouteWithModelClass:modelClass keyPath:keyPath];
}

- (void)routePOST:(NSString * )pathPattern modelClass:(Class)modelClass keyPath:(NSString *)keyPath {
    [self routeGroupForPathPattern:pathPattern].postRoute = [YYHModelRoute POSTRouteWithModelClass:modelClass keyPath:keyPath];
}

- (void)routePUT:(NSString * )pathPattern modelClass:(Class)modelClass keyPath:(NSString *)keyPath {
    [self routeGroupForPathPattern:pathPattern].putRoute = [YYHModelRoute PUTRouteWithModelClass:modelClass keyPath:keyPath];
}

- (void)routeDELETE:(NSString * )pathPattern modelClass:(Class)modelClass keyPath:(NSString *)keyPath {
    [self routeGroupForPathPattern:pathPattern].deleteRoute = [YYHModelRoute DELETERouteWithModelClass:modelClass keyPath:keyPath];
}

#pragma mark - Model Request API

- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters success:(YYHModelRequestSuccess)success failure:(YYHModelRequestFailure)failure {
    YYHModelRoute *modelRoute = [self modelRouteForPath:path method:[YYHModelRoute getRequestMethod]];
    NSAssert(modelRoute != nil, @"Could not find modelRoute for path \"%@\"", path);
    
    [self.sessionManager GET:[self requestPathForModelPath:path]
                  parameters:parameters
                     success:[self requestSuccessBlockWithModelRoute:modelRoute success:success failure:failure]
                     failure:[self requestFailureBlockWithModelRoute:modelRoute success:success failure:failure]];
}

- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters success:(YYHModelRequestSuccess)success failure:(YYHModelRequestFailure)failure {
    YYHModelRoute *modelRoute = [self modelRouteForPath:path method:[YYHModelRoute postRequestMethod]];
    NSAssert(modelRoute != nil, @"Could not find modelRoute for path \"%@\"", path);
    
    [self.sessionManager POST:[self requestPathForModelPath:path]
                  parameters:parameters
                     success:[self requestSuccessBlockWithModelRoute:modelRoute success:success failure:failure]
                     failure:[self requestFailureBlockWithModelRoute:modelRoute success:success failure:failure]];
}

- (void)PUT:(NSString *)path parameters:(NSDictionary *)parameters success:(YYHModelRequestSuccess)success failure:(YYHModelRequestFailure)failure {
    YYHModelRoute *modelRoute = [self modelRouteForPath:path method:[YYHModelRoute putRequestMethod]];
    NSAssert(modelRoute != nil, @"Could not find modelRoute for path \"%@\"", path);
    
    [self.sessionManager PUT:[self requestPathForModelPath:path]
                   parameters:parameters
                      success:[self requestSuccessBlockWithModelRoute:modelRoute success:success failure:failure]
                      failure:[self requestFailureBlockWithModelRoute:modelRoute success:success failure:failure]];
}

- (void)DELETE:(NSString *)path parameters:(NSDictionary *)parameters success:(YYHModelRequestSuccess)success failure:(YYHModelRequestFailure)failure {
    YYHModelRoute *modelRoute = [self modelRouteForPath:path method:[YYHModelRoute deleteRequestMethod]];
    NSAssert(modelRoute != nil, @"Could not find modelRoute for path \"%@\"", path);
    
    [self.sessionManager DELETE:[self requestPathForModelPath:path]
                     parameters:parameters
                        success:[self requestSuccessBlockWithModelRoute:modelRoute success:success failure:failure]
                        failure:[self requestFailureBlockWithModelRoute:modelRoute success:success failure:failure]];
}

#pragma mark - Request Handlers

- (void (^)(NSURLSessionDataTask *task, id responseObject))requestSuccessBlockWithModelRoute:(YYHModelRoute *)modelRoute
                                                                                     success:(YYHModelRequestSuccess)success
                                                                                     failure:(YYHModelRequestFailure)failure {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        if (modelRoute.keyPath != nil) {
            responseObject = [responseObject valueForKeyPath:modelRoute.keyPath];
        }
        
        NSError *serializationError = nil;
        id model = [self serializedModelForResponseObject:responseObject modelClass:modelRoute.modelClass error:&serializationError];
        
        if (serializationError && failure) {
            failure(serializationError);
        }
        
        if (success && model) {
            success(task, responseObject, model);
        } else if (failure) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Model serialization failure", @""),
                                       NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Model serialization resulted in nil value. Expected object of type %@ from the key path '%@'", @""), NSStringFromClass(modelRoute.modelClass), modelRoute.keyPath],
                                       };
            failure([NSError errorWithDomain:YYHModelRouterErrorDomain code:YYHModelRouterErrorSerialization userInfo:userInfo]);
        }
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))requestFailureBlockWithModelRoute:(YYHModelRoute *)modelRoute
                                                                                  success:(YYHModelRequestSuccess)success
                                                                                  failure:(YYHModelRequestFailure)failure {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    };
}

#pragma mark - Serialization

- (id)serializedModelForResponseObject:(id)responseObject modelClass:(Class)modelClass error:(NSError **)error {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        return [self serializedModelForJSONDictionary:responseObject modelClass:modelClass error:error];
    } else if ([responseObject isKindOfClass:[NSArray class]]) {
        return [self serializedModelsForJSONArray:responseObject modelClass:modelClass error:error];
    }
    return nil;
}

- (id)serializedModelForJSONDictionary:(NSDictionary *)jsonDictionary modelClass:(Class)modelClass error:(NSError **)error {
    if (self.modelSerializer) {
        return [self.modelSerializer modelForJSONDictionary:jsonDictionary modelClass:modelClass error:error];
    } else {
        return jsonDictionary;
    }
}

- (id)serializedModelsForJSONArray:(NSArray *)jsonArray modelClass:(Class)modelClass error:(NSError **)error {
    if (self.modelSerializer) {
        return [self.modelSerializer modelsForJSONArray:jsonArray modelClass:modelClass error:error];
    } else {
        return jsonArray;
    }
}

#pragma mark - Paths

- (NSString *)requestPathForModelPath:(NSString *)modelPath {
    return modelPath;
}

@end
