//
//  SimpleGeoController.m
//  SimpleApp
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

- (void)dealloc
{
    [client dealloc];
    [super dealloc];
}

- (NSString *)consumerKey
{
    return [consumerKeyField stringValue];
}

- (NSString *)consumerSecret
{
    return [consumerSecretField stringValue];
}

- (NSURL *)apiURL
{
    return [NSURL URLWithString:[apiHostnameField stringValue]];
}

- (SimpleGeo *)client
{
    // invalidate the client when any of the fields change
    if (client) {
        if (! [[client url] isEqual:[self apiURL]] ||
            ! [[client consumerKey] isEqual:[self consumerKey]] ||
            ! [[client consumerSecret] isEqual:[self consumerSecret]]) {
            NSLog(@"Invalidating current client; credentials and/or URL changed.");
            [client release];
            client = nil;
        }
    }

    if (! client) {
        client = [[SimpleGeo clientWithDelegate:self
                                    consumerKey:[self consumerKey]
                                 consumerSecret:[self consumerSecret]
                                            URL:[self apiURL]] retain];
    }

    return client;
}

#pragma mark SimpleGeoDelegate methods

- (void)requestDidFail:(ASIHTTPRequest *)request
{
    NSLog(@"Request failed: %@: %i", [request responseStatusMessage], [request responseStatusCode]);
    [outputView setString:[NSString stringWithFormat:@"%@:\n%@",
                           [request responseStatusMessage], [request responseString]]];
}

- (void)requestDidFinish:(ASIHTTPRequest *)request
{
	NSString * responseString = [request responseString];
	NSLog(@"Request finished: %@", responseString);
	NSDictionary *jsonResponse = [responseString yajl_JSON];
	NSString * parsedString = [jsonResponse yajl_JSONStringWithOptions:YAJLGenOptionsBeautify indentString:@"  "];
    [outputView setString:parsedString];
}

@end
