//
//  YYHModelRouter.h
//  YYHModelRouter
//
//  Created by Angelo Di Paolo on 11/25/14.
//  Copyright (c) 2014 Yayuhh. All rights reserved.
//

#import "YYHModelSerialization.h"

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void (^YYHModelRequestSuccess)(NSURLSessionDataTask *task, id responseObject, id model);
typedef void (^YYHModelRequestFailure)(NSError *error);

@interface YYHModelRouter : NSObject

@property (nonatomic, strong, readonly) NSURL *baseURL;
@property (nonatomic, strong, readonly) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) id<YYHModelSerialization> modelSerializer;

/**
 Initialize a model router with a base URL.
 */
- (instancetype)initWithBaseURL:(NSURL *)url;

/**
 Add a route for a GET request.
 @param pathPattern Request path pattern.
 @param modelClass Class of model to load for this route.
 @param keyPath Key path of JSON value used to serialize model.
 */
- (void)routeGET:(NSString * )pathPattern modelClass:(Class)modelClass keyPath:(NSString *)keyPath;

/**
 Add a route for a POST request.
 @param pathPattern Request path pattern.
 @param modelClass Class of model to load for this route.
 @param keyPath Key path of JSON value used to serialize model.
 */
- (void)routePOST:(NSString * )pathPattern modelClass:(Class)modelClass keyPath:(NSString *)keyPath;

/**
 Add a route for a PUT request.
 @param pathPattern Request path pattern.
 @param modelClass Class of model to load for this route.
 @param keyPath Key path of JSON value used to serialize model.
 */
- (void)routePUT:(NSString * )pathPattern modelClass:(Class)modelClass keyPath:(NSString *)keyPath;

/**
 Add a route for a DELETE request.
 @param pathPattern Request path pattern.
 @param modelClass Class of model to load for this route.
 @param keyPath Key path of JSON value used to serialize model.
 */
- (void)routeDELETE:(NSString * )pathPattern modelClass:(Class)modelClass keyPath:(NSString *)keyPath;

/**
 Send a GET request and serialize the response as a model object.
 */
- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters success:(YYHModelRequestSuccess)success failure:(YYHModelRequestFailure)failure;

/**
 Send a POST request and serialize the response as a model object.
 */
- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters success:(YYHModelRequestSuccess)success failure:(YYHModelRequestFailure)failure;

/**
 Send a PUT request and serialize the response as a model object.
 */
- (void)PUT:(NSString *)path parameters:(NSDictionary *)parameters success:(YYHModelRequestSuccess)success failure:(YYHModelRequestFailure)failure;

/**
 Send a DELETE request and serialize the response as a model object.
 */
- (void)DELETE:(NSString *)path parameters:(NSDictionary *)parameters success:(YYHModelRequestSuccess)success failure:(YYHModelRequestFailure)failure;

- (NSString *)requestPathForModelPath:(NSString *)modelPath;

@end
