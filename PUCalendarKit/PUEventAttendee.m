//
//  PUEventAttendee.m
//
//  Created by Maurice Arikoglu, based on MXLCalendarManager Framework by Kiran Panesar created on 09/04/2013.
//  Copyright (c) 2017 Maurice Arikoglu. All rights reserved.
//

#import "PUEventAttendee.h"
#import "NSString+PUCalendarICSEnumerations.h"

@implementation PUEventAttendee

- (id)copyWithZone:(NSZone *)zone {
    
    PUEventAttendee *copy = [[PUEventAttendee allocWithZone:zone] init];
    
    if (copy) {
        
        [copy setUri:[self.uri copyWithZone:zone]];
        [copy setCommonName:[self.commonName copyWithZone:zone]];
        [copy setEmail:[self.email copyWithZone:zone]];
        [copy setStatus:[self.status copyWithZone:zone]];
        [copy setRole:self.role];
    }
    
    return copy;
}

- (id)initWithRole:(PURole)role commonName:(NSString *)commonName email:(NSString *)email status:(NSString*)status andUri:(NSString *)uri {
    
    self = [super init];
    
    if (self) {
        
        self.role = role;
        self.commonName = commonName;
        self.uri = uri;
        self.email = email;
        self.status = status;
    }
    
    return self;
}

+ (instancetype)attendeeForString:(NSString *)attendeeString {
    
    if (attendeeString) {
        
        PUEventAttendee *attendee = [[PUEventAttendee alloc] init];
        
        if (attendee) {
            
            /* Example structure of Attendee:
             
             ATTENDEE;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;CN=Halste
             d Street;X-NUM-GUESTS=0:mailto:ffc.com_j2r0bhi3cup4khh27r2d6koph4@group.cal
             endar.google.com
             
             */
            
            NSScanner *eventScanner = [NSScanner scannerWithString:attendeeString];
            NSString *uri, *attributes = @"";
            
            [eventScanner scanUpToString:@":" intoString:&attributes];
            [eventScanner scanUpToString:@"\n" intoString:&uri];
            
            //Assign the uri if length > 1
            attendee.uri = (uri.length > 1) ? [uri substringFromIndex:1] : nil;
            
            //Scan attributes
            NSScanner *attributesScanner = [NSScanner scannerWithString:attributes];

            NSString *role = @"";
            [attributesScanner scanUpToString:@"ROLE=" intoString:nil];
            [attributesScanner scanUpToString:@";" intoString:&role];
            attendee.role = [[role stringByReplacingOccurrencesOfString:@"ROLE=" withString:@""] roleForICSRoleString];

            NSString *status = @"";
            [attributesScanner scanUpToString:@"PARTSTAT=" intoString:nil];
            [attributesScanner scanUpToString:@";" intoString:&status];
            attendee.status = [status stringByReplacingOccurrencesOfString:@"PARTSTAT=" withString:@""];

            NSString *name = @"";
            attributesScanner = [NSScanner scannerWithString:attributes];
            [attributesScanner scanUpToString:@"CN=" intoString:nil];
            [attributesScanner scanUpToString:@";" intoString:&name];
            attendee.commonName = [name stringByReplacingOccurrencesOfString:@"CN=" withString:@""];;

            NSString *email = @"";
            NSScanner *emailScanner = [NSScanner scannerWithString:attendeeString];
            [emailScanner scanUpToString:@"mailto:" intoString:nil];
            [emailScanner scanUpToString:@"" intoString:&email];
            attendee.email = [email stringByReplacingOccurrencesOfString:@"mailto:" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [email length])];
        }
        
        return attendee;
    } else {
        
        return nil;
    }
}


@end
