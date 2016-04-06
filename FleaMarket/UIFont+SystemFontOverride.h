//
//  UIFont+SystemFontOverride.h
//  FleaMarket
//
//  Created by Zichuan Huang on 19/03/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (SystemFontOverride)

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize;
+ (UIFont *)systemFontOfSize:(CGFloat)fontSize;
+ (UIFont *)preferredFontForTextStyle:(NSString *)style;

@end
