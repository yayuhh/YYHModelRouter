YYHModelRouter
==========

A lightweight utility built on top of AFNetworking for interacting with model objects over RESTful HTTP services.
Provides endpoint-based configuration for automatically serializing JSON request/response payloads into model objects. By default [Mantle](https://github.com/Mantle/Mantle) is used to serialize model objects but custom model serializers can easily be built to work with any model framework.

## Installation

    pod "YYHModelRouter"

For use without [Mantle](https://github.com/Mantle/Mantle) install the `core` subspec.

    pod "YYHModelRouter/core"

## Usage

### Adding Routes

    YYHModelRouter *modelRouter = [[YYHModelRouter alloc] initWithBaseURL:[NSURL URLWithString:@"http://foo.bar"]];
    [modelRouter routeGET:@"/user/:userId" modelClass:[UserModel class] keyPath:@"user"];

### Requesting Models

    YYHModelRouter *modelRouter
    [modelRouter GET:@"/users/12345" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject, id model) {
        UserModel *user = model;
        self.userView.nameLabel.text = user.name;
    } failure:^(NSError *error) {

    }];
