//
//  MyClass.m
//  
//
//  Created by Scott Ahten on 2/28/21.
//

#import "MyObject.h"
#import "NameGenerator+LastName.h"

@import MyPackageSwift;

@implementation MyObject

- (NSString*)name
{
    NameGenerator *generator = [[NameGenerator alloc] init];
    return [NSString stringWithFormat:@"%@ %@", [generator generateFirstName], [generator generateLastName]];
}

@end
