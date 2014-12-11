YYHModelRouter
==========

A lightweight utility built on top of [AFNetworking](https://github.com/AFNetworking/AFNetworking) for interacting with model objects over RESTful HTTP services.
Provides endpoint-based configuration for automatically serializing JSON request/response payloads into model objects. By default [Mantle](https://github.com/Mantle/Mantle) is used to serialize model objects but custom model serializers can easily be built to work with any model framework.

## Installation

    pod "YYHModelRouter"

For use without [Mantle](https://github.com/Mantle/Mantle) install the `core` subspec.

    pod "YYHModelRouter/core"

## Usage

### Adding Routes

Route responses of `GET` requests that match the path pattern `@"/users/:userID"` to the model class `UserModel`.

    YYHModelRouter *modelRouter = [[YYHModelRouter alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.bar"]];
    [modelRouter routeGET:@"/user/:userId" responseModelClass:[UserModel class] responseKeyPath:@"user"];

### Requesting Models

Send a get request for `@"/users/12345"` and serialize the response as a `UserModel` object.

    YYHModelRouter *modelRouter;
    [modelRouter GET:@"/users/12345" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject, id model) {
        UserModel *user = model;
        self.userView.nameLabel.text = user.name;
    } failure:^(NSError *error) {

    }];

Send a `POST` request and serialize the model as JSON in the request body.

    Comment *comment = [[Comment alloc] init]
    comment.message = @"YAYUHH";
    [modelRouter POST:@"/comments" model:comment success:success failure:failure];
