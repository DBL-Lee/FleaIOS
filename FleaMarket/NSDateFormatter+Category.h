//
//  NSDateFormatter+Category.h
//  FleaMarket
//
//  Created by Zichuan Huang on 01/04/2016.
//  Copyright © 2016 Zichuan Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Category)

+ (id)dateFormatter;
+ (id)dateFormatterWithFormat:(NSString *)dateFormat;

+ (id)defaultDateFormatter;/*yyyy-MM-dd HH:mm:ss*/

@end
