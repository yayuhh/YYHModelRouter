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

NSString * const YYHModelRouteGroupTypRequest = @"YYHModelRouteGroupTypRequest";
NSString * const YYHModelRouteGroupTypeResponse = @"YYHModelRouteGroupTypeResponse";

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
@property (nonatomic, strong) NSMutableDictionary *requestRouteMap;
@property (nonatomic, strong) NSMutableDictionary *responseRouteMap;

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

#pragma mark - Routing Core

- (YYHModelRouteGroup *)routeGroupForPathPattern:(NSString *)pathPattern groupType:(NSString *)groupType {
    YYHModelRouteGroup *group;
    
    if ([groupType isEqualToString:YYHModelRouteGroupTypRequest]) {
        group = self.requestRouteMap[pathPattern];
    } else if ([groupType isEqualToString:YYHModelRouteGroupTypeResponse]) {
        group = self.responseRouteMap[pathPattern];
    }
    
    if (!group) {
        group = [[YYHModelRouteGroup alloc] init];
        
        if ([groupType isEqualToString:YYHModelRouteGroupTypRequest]) {
            self.requestRouteMap[pathPattern] = group;
        } else if ([groupType isEqualToString:YYHModelRouteGroupTypeResponse]) {
            self.responseRouteMap[pathPattern] = group;
        }
    }
    
    return group;
}

- (YYHModelRouteGroup *)routeGroupForPath:(NSString *)path groupType:(NSString *)groupType {
    NSDictionary *routeMap;
    
    if ([groupType isEqualToString:YYHModelRouteGroupTypRequest]) {
        routeMap = self.requestRouteMap;
    } else if ([groupType isEqualToString:YYHModelRouteGroupTypeResponse]) {
        routeMap = self.responseRouteMap;
    }
    
    for (NSString *testPathPattern in routeMap) {
        if ([self pathPattern:testPathPattern matchesPath:path]) {
            return routeMap[testPathPattern];
        }
    }
    
    return nil;
}

- (YYHModelRoute *)modelRouteForPath:(NSString *)path method:(NSString *)method groupType:(NSString *)groupType {
    return [[self routeGroupForPath:path groupType:groupType] routeForRequestMethod:method];
}

#pragma mark - Request Routing

- (NSMutableDictionary *)requestRouteMap {
    if (!_requestRouteMap) {
        _requestRouteMap = [[NSMutableDictionary alloc] init];
    }

    return _requestRouteMap;
}

- (YYHModelRouteGroup *)requestRouteGroupForPathPattern:(NSString *)pathPattern {
    return [self routeGroupForPathPattern:pathPattern groupType:YYHModelRouteGroupTypRequest];
}

- (YYHModelRoute *)requestModelRouteForPath:(NSString *)path method:(NSString *)method {
    return [self modelRouteForPath:path method:method groupType:YYHModelRouteGroupTypRequest];
}

#pragma mark - Response Routing

- (NSMutableDictionary *)responseRouteMap {
    if (!_responseRouteMap) {
        _responseRouteMap = [[NSMutableDictionary alloc] init];
    }
    
    return _responseRouteMap;
}

- (YYHModelRouteGroup *)responseRouteGroupForPathPattern:(NSString *)pathPattern {
    return [self routeGroupForPathPattern:pathPattern groupType:YYHModelRouteGroupTypeResponse];
}

- (YYHModelRoute *)responseModelRouteForPath:(NSString *)path method:(NSString *)method {
    return [self modelRouteForPath:path method:method groupType:YYHModelRouteGroupTypeResponse];
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

- (void)routeGET:(NSString *)pathPattern responseModelClass:(Class)responseModelClass responseKeyPath:(NSString *)responseKeyPath {
    [self responseRouteGroupForPathPattern:pathPattern].getRoute = [YYHModelRoute GETRouteWithModelClass:responseModelClass keyPath:responseKeyPath];

}

- (void)routePOST:(NSString *)pathPattern requestKeyPath:(NSString *)requestKeyPath {
    [self requestRouteGroupForPathPattern:pathPattern].postRoute = [YYHModelRoute GETRouteWithModelClass:Nil keyPath:requestKeyPath];
}

- (void)routePOST:(NSString *)pathPattern responseModelClass:(Class)responseModelClass responseKeyPath:(NSString *)responseKeyPath {
    [self responseRouteGroupForPathPattern:pathPattern].postRoute = [YYHModelRoute GETRouteWithModelClass:responseModelClass keyPath:responseKeyPath];
    
}

- (void)routePUT:(NSString *)pathPattern requestKeyPath:(NSString *)requestKeyPath {
    [self requestRouteGroupForPathPattern:pathPattern].putRoute = [YYHModelRoute GETRouteWithModelClass:Nil keyPath:requestKeyPath];
}

- (void)routePUT:(NSString *)pathPattern responseModelClass:(Class)responseModelClass responseKeyPath:(NSString *)responseKeyPath {
    [self responseRouteGroupForPathPattern:pathPattern].putRoute = [YYHModelRoute GETRouteWithModelClass:responseModelClass keyPath:responseKeyPath];
}

- (void)routeDELETE:(NSString *)pathPattern requestKeyPath:(NSString *)requestKeyPath {
    [self requestRouteGroupForPathPattern:pathPattern].deleteRoute = [YYHModelRoute GETRouteWithModelClass:Nil keyPath:requestKeyPath];
}

- (void)routeDELETE:(NSString *)pathPattern responseModelClass:(Class)responseModelClass responseKeyPath:(NSString *)responseKeyPath {
    [self responseRouteGroupForPathPattern:pathPattern].deleteRoute = [YYHModelRoute GETRouteWithModelClass:responseModelClass keyPath:responseKeyPath];
}

#pragma mark - Model Request API

- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters success:(YYHModelRequestSuccess)success failure:(YYHModelRequestFailure)failure {
    YYHModelRoute *modelRoute = [self responseModelRouteForPath:path method:[YYHModelRoute getRequestMethod]];
    NSAssert(modelRoute != nil, @"Could not find model route for GET request path \"%@\"", path);
    
    [self.sessionManager GET:[self requestPathForModelPath:path]
                  parameters:parameters
                     success:[self requestSuccessBlockWithResponseRoute:modelRoute success:success failure:failure]
                     failure:[self requestFailureBlockWithFailure:failure]];
}

- (void)POST:(NSString *)path model:(id)model success:(YYHModelRequestSuccess)success failure:(YYHModelRequestFailure)failure {
    YYHModelRoute *requestRoute = [self requestModelRouteForPath:path method:[YYHModelRoute postRequestMethod]];
    YYHModelRoute *responseRoute = [self responseModelRouteForPath:path method:[YYHModelRoute postRequestMethod]];

    [self.sessionManager POST:[self requestPathForModelPath:path]
                  parameters:[self JSONPayloadForModel:model requestRoute:requestRoute]
                     success:[self requestSuccessBlockWithResponseRoute:responseRoute success:success failure:failure]
                     failure:[self requestFailureBlockWithFailure:failure]];
}

- (void)PUT:(NSString *)path model:(id)model success:(YYHModelRequestSuccess)success failure:(YYHModelRequestFailure)failure {
    YYHModelRoute *requestRoute = [self requestModelRouteForPath:path method:[YYHModelRoute putRequestMethod]];
    YYHModelRoute *responseRoute = [self responseModelRouteForPath:path method:[YYHModelRoute putRequestMethod]];

    [self.sessionManager PUT:[self requestPathForModelPath:path]
                   parameters:[self JSONPayloadForModel:model requestRoute:requestRoute]
                      success:[self requestSuccessBlockWithResponseRoute:responseRoute success:success failure:failure]
                      failure:[self requestFailureBlockWithFailure:failure]];
}

- (void)DELETE:(NSString *)path model:(id)model success:(YYHModelRequestSuccess)success failure:(YYHModelRequestFailure)failure {
    YYHModelRoute *requestRoute = [self requestModelRouteForPath:path method:[YYHModelRoute deleteRequestMethod]];
    YYHModelRoute *responseRoute = [self responseModelRouteForPath:path method:[YYHModelRoute deleteRequestMethod]];
    
    [self.sessionManager DELETE:[self requestPathForModelPath:path]
                     parameters:[self JSONPayloadForModel:model requestRoute:requestRoute]
                        success:[self requestSuccessBlockWithResponseRoute:responseRoute success:success failure:failure]
                        failure:[self requestFailureBlockWithFailure:failure]];
}

#pragma mark - Request Handlers

- (void (^)(NSURLSessionDataTask *task, id responseObject))requestSuccessBlockWithResponseRoute:(YYHModelRoute *)responseRoute
                                                                                        success:(YYHModelRequestSuccess)success
                                                                                        failure:(YYHModelRequestFailure)failure {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        if (responseRoute.keyPath != nil) {
            responseObject = [responseObject valueForKeyPath:responseRoute.keyPath];
        }
        
        NSError *serializationError = nil;
        id model = responseRoute != nil ? [self serializedModelForResponseObject:responseObject modelClass:responseRoute.modelClass error:&serializationError] : nil;
        
        if (serializationError && failure) {
            failure(serializationError);
        }
        
        if (success) {
            success(task, responseObject, model);
        }
    };
}

- (void (^)(NSURLSessionDataTask *task, NSError *error))requestFailureBlockWithFailure:(YYHModelRequestFailure)failure {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    };
}

#pragma mark - Serialization - Request


- (NSDictionary *)JSONPayloadForModel:(id)model requestRoute:(YYHModelRoute *)modelRoute {
    id modelJSON = [self modelJSONForModel:model];

    if (modelRoute.keyPath) {
        NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
        [payload setValue:modelJSON forKeyPath:modelRoute.keyPath];
        return [payload copy];
    } else {
        return modelJSON;
    }
}

- (id)modelJSONForModel:(id)model {
    if ([model isKindOfClass:[NSArray class]]) {
        return [self JSONArrayForModels:model];;
    } else {
        return [self JSONDictionaryForModel:model];
    }
}

- (NSArray *)JSONArrayForModels:(NSArray *)models {
    if (self.modelSerializer) {
        return [self.modelSerializer JSONArrayWithModels:models];
    } else {
        return models;
    }
}

- (NSDictionary *)JSONDictionaryForModel:(id)model {
    if (self.modelSerializer) {
        return [self.modelSerializer JSONDictionaryWithModel:model];
    } else {
        return model;
    }
}

#pragma mark - Serialization - Response

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
