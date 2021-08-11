//
//  AIFXMLParser.h
//  AIFDemo
//
//  Created by leoo on 2021/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AIFXMLParser : NSObject

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;
@end

NS_ASSUME_NONNULL_END
