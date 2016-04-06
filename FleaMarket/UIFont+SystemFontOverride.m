//
//  UIFont+SystemFontOverride.m
//  FleaMarket
//
//  Created by Zichuan Huang on 19/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

#import "UIFont+SystemFontOverride.h"

@implementation UIFont (SystemFontOverride)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont systemFontOfSize:fontSize];
}

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize {
    return [UIFont systemFontOfSize:fontSize weight:UIFontWeightLight];
}

+ (UIFont *)preferredFontForTextStyle:(NSString *)style
{
    if ([style isEqualToString:UIFontTextStyleBody])
        return [UIFont systemFontOfSize:17];
    if ([style isEqualToString:UIFontTextStyleHeadline])
        return [UIFont boldSystemFontOfSize:17];
    if ([style isEqualToString:UIFontTextStyleSubheadline])
        return [UIFont systemFontOfSize:15];
    if ([style isEqualToString:UIFontTextStyleFootnote])
        return [UIFont systemFontOfSize:13];
    if ([style isEqualToString:UIFontTextStyleCaption1])
        return [UIFont systemFontOfSize:12];
    if ([style isEqualToString:UIFontTextStyleCaption2])
        return [UIFont systemFontOfSize:11];
    return [UIFont systemFontOfSize:17];
}

#pragma clang diagnostic pop

@end
