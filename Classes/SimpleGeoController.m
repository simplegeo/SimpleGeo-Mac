//
//  SimpleGeoController.m
//  SimpleGeo
//
//  Copyright (c) 2010, SimpleGeo Inc.
//  All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SimpleGeoController.h"

@implementation SimpleGeoController

#pragma mark Accessors

- (NSString *)consumerKey
{
    return [consumerKeyField stringValue];
}

- (NSString *)consumerSecret
{
    return [consumerSecretField stringValue];
}

- (SimpleGeo *)client
{
    [client release];
    client = [[SimpleGeo clientWithConsumerKey:self.consumerKey
                                consumerSecret:self.consumerSecret] retain];
    return client;
}

#pragma mark Delegate

- (void)requestDidSucceed:(id)response
{
    NSLog(@"Request finished: %@", (NSDictionary *)response);
    [outputView setString:[(NSDictionary *)response description]];
    [outputView scrollPoint:NSMakePoint(0.0,0.0)];
}

- (void)requestDidFail:(NSError *)error
{
    NSLog(@"Request failed: %@", error);
    [outputView setString:error.description];
    [outputView scrollPoint:NSMakePoint(0.0,0.0)];
}

#pragma mark Memory

- (void)dealloc
{
    [client dealloc];
    [super dealloc];
}

@end
