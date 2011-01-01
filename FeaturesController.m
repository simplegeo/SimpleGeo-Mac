//
//  FeaturesController.m
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

#import <SimpleGeo/SimpleGeo+Places.h>
#import "FeaturesController.h"

@implementation FeaturesController

@synthesize currentFeature;

- (IBAction)deleteFeature:(id)sender
{
    [[self client] deletePlace:[[self currentFeature] featureId]];
}

- (IBAction)loadFeature:(id)sender
{
    [[self client] getFeatureWithHandle:[handleField stringValue]];
}

- (IBAction)saveFeature:(id)sender
{
    NSLog(@"Pending changes: %@", pendingChanges);
    SGFeature *pendingFeature = [SGFeature featureWithGeometry:[SGPoint pointWithLatitude:pendingLatitude
                                                                                longitude:pendingLongitude]
                                                    properties:pendingChanges];

    [[self client] updatePlace:[[self currentFeature] featureId]
                          with:pendingFeature
					   private:NO];
}

#pragma mark NSTableViewDataSource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [[[self currentFeature] properties] count] + 3;
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex
{
    if (rowIndex == 0) {
        if ([[aTableColumn identifier] isEqual:@"name"]) {
            return @"handle";
        } else {
            return [[self currentFeature] featureId];
        }
    } else if (rowIndex == 1) {
        if ([[aTableColumn identifier] isEqual:@"name"]) {
            return @"latitude";
        } else {
            SGPoint *geometry = (SGPoint *)[[self currentFeature] geometry];
            return [NSNumber numberWithDouble:[geometry latitude]];
        }
    } else if (rowIndex == 2) {
        if ([[aTableColumn identifier] isEqual:@"name"]) {
            return @"longitude";
        } else {
            SGPoint *geometry = (SGPoint *)[[self currentFeature] geometry];
            return [NSNumber numberWithDouble:[geometry longitude]];
        }
    } else {
        NSArray *keys = [[[self currentFeature] properties] allKeys];
        id key = [keys objectAtIndex:rowIndex - 3];
        id value = [[[self currentFeature] properties] objectForKey:key];

        if ([[aTableColumn identifier] isEqual:@"name"]) {
            return [keys objectAtIndex:rowIndex - 3];
        } else {
            // TODO replace the NSTableView with an NSOutlineView to handle nested properties
            if ([value isKindOfClass:[NSString class]]) {
                id val;
                if (val = [pendingChanges objectForKey:key]) {
                    return val;
                } else {
                    return value;
                }
            } else {
                return [[value description] stringByReplacingOccurrencesOfString:@"\n"
                                                                      withString:@""];
            }
        }
    }

    return nil;
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
              row:(NSInteger)rowIndex
{
    if ([[aTableColumn identifier] isEqual:@"value"]) {
        if (! pendingChanges) {
            pendingChanges = [[NSMutableDictionary dictionary] retain];
        }

        if (rowIndex == 1) {
            pendingLatitude = [anObject doubleValue];
        } else if (rowIndex == 2) {
            pendingLongitude = [anObject doubleValue];
        } else if (rowIndex > 2) {
            NSArray *keys = [[[self currentFeature] properties] allKeys];
            id key = [keys objectAtIndex:rowIndex - 3];
            id oldValue = [[[self currentFeature] properties] objectForKey:key];

            if ([oldValue isKindOfClass:[NSString class]]) {
                [pendingChanges setObject:anObject
                                   forKey:key];
            }
        }
    }
}

#pragma mark SimpleGeoDelegate methods

- (void)didDeletePlace:(NSString *)handle
                 token:(NSString *)token
{
    [deleteButton setEnabled:NO];
    [editButton setEnabled:NO];
}

- (void)didLoadFeature:(SGFeature *)feature
                handle:(NSString *)handle
{
    [self setCurrentFeature:feature];

    // editing is only allowed for things w/ Point geometries
    if ([[feature geometry] isKindOfClass:[SGPoint class]]) {
        SGPoint *geometry = (SGPoint *)[feature geometry];
        pendingLatitude = [geometry latitude];
        pendingLongitude = [geometry longitude];

        [deleteButton setEnabled:YES];
        [editButton setEnabled:YES];
    } else {
        [deleteButton setEnabled:NO];
        [editButton setEnabled:NO];
    }
}

- (void)didUpdatePlace:(NSString *)handle
                 token:(NSString *)token
{
    [editPanel close];
}

@end
