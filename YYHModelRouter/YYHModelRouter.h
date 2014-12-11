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
 Add a route for a GET response.
 @param pathPattern Path pattern that matches the path of the originating request.
 @param responseModelClass Class of model that will be used to serialize the response.
 @param responseKeyPath Key path of JSON value that will be used serialized as the model.
 */
- (void)routeGET:(NSString *)pathPattern responseModelClass:(Class)responseModelClass responseKeyPath:(NSString *)responseKeyPath;

/**
 Add a route for a POST request.
 @param pathPattern Path pattern that matches the path of the request.
 @param requestKeyPath Optional key path to use when setting the value of the JSON payload.
 */
- (void)routePOST:(NSString *)pathPattern requestKeyPath:(NSString *)requestKeyPath;

/**
 Add a route for a POST response.
 @param pathPattern Path pattern that matches the path of the originating request.
 @param responseModelClass Class of model that will be used to serialize the response.
 @param responseKeyPath Key path of JSON value that will be used serialized as the model.
 */
- (void)routePOST:(NSString *)pathPattern responseModelClass:(Class)responseModelClass responseKeyPath:(NSString *)responseKeyPath;

/**
 Add a route for a PUT request.
 @param pathPattern Path pattern that matches the path of the request.
 @param requestKeyPath Optional key path to use when setting the value of the JSON payload.
 */
- (void)routePUT:(NSString *)pathPattern requestKeyPath:(NSString *)requestKeyPath;

/**
 Add a route for a POST response.
 @param pathPattern Path pattern that matches the path of the originating request.
 @param responseModelClass Class of model that will be used to serialize the response.
 @param responseKeyPath Key path of JSON value that will be used serialized as the model.
 */
- (void)routePUT:(NSString *)pathPattern responseModelClass:(Class)responseModelClass responseKeyPath:(NSString *)responseKeyPath;

/**
 Add a route for a DELETE request.
 @param pathPattern Path pattern that matches the path of the request.
 @param requestKeyPath Optional key path to use when setting the value of the JSON payload.
 */
- (void)routeDELETE:(NSString *)pathPattern requestKeyPath:(NSString *)requestKeyPath;

/**
 Add a route for a POST response.
 @param pathPattern Path pattern that matches the path of the originating request.
 @param responseModelClass Class of model that will be used to serialize the response.
 @param responseKeyPath Key path of JSON value that will be used serialized as the model.
 */
- (void)routeDELETE:(NSString *)pathPattern responseModelClass:(Class)responseModelClass responseKeyPath:(NSString *)responseKeyPath;

/**
 Send a GET request and serialize the response as a model object.
 */
- (void)GET:(NSString *)path
 parameters:(NSDictionary *)parameters
    success:(YYHModelRequestSuccess)success
    failure:(YYHModelRequestFailure)failure;

/**
 Send a POST request and serialize the response as a model object.
 */
- (void)POST:(NSString *)path
       model:(id)model
     success:(YYHModelRequestSuccess)success
     failure:(YYHModelRequestFailure)failure;

/**
 Send a PUT request and serialize the response as a model object.
 */
- (void)PUT:(NSString *)path
      model:(id)model
    success:(YYHModelRequestSuccess)success
    failure:(YYHModelRequestFailure)failure;

/**
 Send a DELETE request and serialize the response as a model object.
 */
- (void)DELETE:(NSString *)path
         model:(id)model
       success:(YYHModelRequestSuccess)success
       failure:(YYHModelRequestFailure)failure;

/**
 Constructs a request path from a model path. Override to customize the request path
 that will be used to construct the final URL of the HTTP request.
 @param modelPath Relative path
 @return Path used to along with the baseURL to construct the final URL of the HTTP request.
 */
- (NSString *)requestPathForModelPath:(NSString *)modelPath;

@end
