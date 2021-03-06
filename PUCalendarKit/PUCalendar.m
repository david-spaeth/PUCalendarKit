//
//  PUCalendar.m
//
//  Created by Maurice Arikoglu, based on MXLCalendarManager Framework by Kiran Panesar created on 09/04/2013.
//  Copyright (c) 2017 Maurice Arikoglu. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "PUCalendar.h"
#import "PUCalendarEvent.h"

@interface PUCalendar ()

@property (nonatomic, retain) NSDictionary *daysOfEvents;
@property (nonatomic, retain) NSDictionary *loadedEvents;

//@property (nonatomic, retain) NSCalendar *calendar;

@end

@implementation PUCalendar

- (id)copyWithZone:(NSZone *)zone {
    
    PUCalendar *copy = [[PUCalendar allocWithZone:zone] init];
    
    if (copy) {
        
        [copy setEvents:[self.events copyWithZone:zone]];
        [copy setTimeZone:[self.timeZone copyWithZone:zone]];
        
        [copy setDaysOfEvents:[self.daysOfEvents copyWithZone:zone]];
        [copy setLoadedEvents:[self.loadedEvents copyWithZone:zone]];
//        [copy setCalendar:[self.calendar copyWithZone:zone]];
    }
    
    return copy;
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.events = [[NSArray alloc] init];
        self.daysOfEvents = [[NSDictionary alloc] init];
        self.loadedEvents = [[NSDictionary alloc] init];
    }
    
    return self;
}

- (void)addEvent:(PUCalendarEvent *)event {
    
    NSMutableArray *mutableEvents = [NSMutableArray arrayWithArray:self.events.mutableCopy];
    [mutableEvents addObject:event];
    self.events = mutableEvents.copy;
}

- (void)addEvent:(PUCalendarEvent *)event onDateWithDay:(NSInteger)day month:(NSInteger)month andYear:(NSInteger)year {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyddMM"];

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth| NSCalendarUnitYear fromDate:[NSDate date]];
    
    components.day = day;
    components.month = month;
    components.year = year;
    
    [self addEvent:event onDateRepresentedAsString:[dateFormatter stringFromDate:[[NSCalendar currentCalendar] dateFromComponents:components]]];
}

- (void)addEvent:(PUCalendarEvent *)event onDateRepresentedAsString:(NSString *)dateString {
    // Check if the event has already been logged today
    for (PUCalendarEvent *currentEvent in self.daysOfEvents[dateString]) {
        
        if ([currentEvent.eventUniqueId isEqualToString:event.eventUniqueId]) {
            
            return;
        }
    }
    
    // If there are already events for this date...
    if ([self.daysOfEvents objectForKey:dateString]) {
        
        // If the event has already been logged on this day, just return.
        if ([[self.daysOfEvents objectForKey:dateString] containsObject:event]) {
            
            return;
        }

        // If not, add it to the day
        NSMutableDictionary *mutableDayEvents = [NSMutableDictionary dictionaryWithDictionary:self.daysOfEvents.mutableCopy];
        [[mutableDayEvents objectForKey:dateString] addObject:event];
        self.daysOfEvents = mutableDayEvents.copy;
        
    } else {
        // If there are no current dates on today, create a new array and save it for the day
        NSMutableDictionary *mutableDayEvents = [NSMutableDictionary dictionaryWithDictionary:self.daysOfEvents.mutableCopy];
        [mutableDayEvents setObject:[NSMutableArray arrayWithObject:event] forKey:dateString];
        self.daysOfEvents = mutableDayEvents.copy;
    }
}

- (void)addEvent:(PUCalendarEvent *)event onDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyddMM"];
    
    [self addEvent:event onDateRepresentedAsString:[dateFormatter stringFromDate:date]];
}

- (void)loadedAllEventsForDate:(NSDate *)date {
    
    NSMutableDictionary *mutableLoadedEvents = [NSMutableDictionary dictionaryWithDictionary:self.loadedEvents.mutableCopy];
    [mutableLoadedEvents setObject:[NSNumber numberWithBool:YES] forKey:date];
    self.loadedEvents = mutableLoadedEvents.copy;
}

- (BOOL)hasLoadedAllEventsForDate:(NSDate *)date {
    
    return [self.loadedEvents objectForKey:date];
}

- (NSArray *)eventsForDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyddMM"];
    
    NSMutableArray *mutableEventsForDay = [self.daysOfEvents objectForKey:[dateFormatter stringFromDate:date]];
    
    //Create a sorted copy of the events for date
    NSMutableArray *mutableEventsToSetAndReturn = [NSMutableArray arrayWithArray:[mutableEventsForDay sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {

        PUCalendarEvent *firstEvent = obj1;
        PUCalendarEvent *secondEvent = obj2;

        //We compare time only because initial start dates might be different because of recurrence
        NSDateComponents *firstComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:firstEvent.eventStartDate];
        NSDateComponents *secondComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:secondEvent.eventStartDate];
        
        return [[[NSCalendar currentCalendar] dateFromComponents:firstComponents] compare:[[NSCalendar currentCalendar] dateFromComponents:secondComponents]];
    }]];
    
    //Set the sorted array and return a copy
    NSMutableDictionary *mutableDayEvents = [NSMutableDictionary dictionaryWithDictionary:self.daysOfEvents.mutableCopy];
    [mutableDayEvents setObject:mutableEventsToSetAndReturn forKey:[dateFormatter stringFromDate:date]];
    self.daysOfEvents = mutableDayEvents.copy;
    
    return mutableEventsToSetAndReturn.copy;
}

@end
