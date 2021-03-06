// Copyright 2008 Google Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not
// use this file except in compliance with the License.  You may obtain a copy
// of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations under
// the License.

#import "Layer.h"
#import "Simulator.h"
#import "SimulatorObject.h"

@implementation Simulator
+ (NSString *)className {
  return @"Simulator";
}

+ (NSSet *)properties {
  return [NSSet setWithObjects:@"timeStep", nil];
}

+ (NSSet *)methods {
  return [NSSet setWithObjects:@"addSimulatorObject", @"runInLayer", @"toString", nil];
}

- (id)initWithArguments:(NSArray *)arguments {
  if ((self = [super initWithArguments:arguments])) {
    objects_ = [[NSMutableArray alloc] init];
    timeStep_ = 1.0 / 6.0;
  }
  
  return self;
}

- (void)dealloc {
  [objects_ release];
  [super dealloc];
}

- (void)setTimeStep:(CGFloat)ts {
  timeStep_ = ts;
}

- (CGFloat)timeStep {
  return timeStep_;
}

- (void)addSimulatorObject:(NSArray *)arguments {
  if ([arguments count] == 1) {
    SimulatorObject *so = [RuntimeObject coerceObject:[arguments objectAtIndex:0] toClass:[SimulatorObject class]];

    // Only add if it's not already there.
    if (so && ![objects_ containsObject:so])
        [objects_ addObject:so];
  }  
}

- (void)runInLayer:(NSArray *)arguments {
  if ([arguments count] == 2) {
    Layer *layer = [RuntimeObject coerceArray:arguments objectAtIndex:0 toClass:[Layer class]];
    CGFloat time = [RuntimeObject coerceObjectToDouble:[arguments objectAtIndex:1]];
    CGFloat current = 0;
    
    [objects_ makeObjectsPerformSelector:@selector(setLayer:) withObject:layer];
    [objects_ makeObjectsPerformSelector:@selector(setTimeStep:) withObject:[NSNumber numberWithFloat:timeStep_]];
    
    while (current < time) {
      [objects_ makeObjectsPerformSelector:@selector(step)];
      current += timeStep_;
    }
  }
}

- (NSString *)toString {
  return [NSString stringWithFormat:@"Simulation with %lu objects", (unsigned long)[objects_ count]];
}

@end
