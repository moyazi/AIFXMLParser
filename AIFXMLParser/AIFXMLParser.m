//
//  AIFXMLParser.m
//  AIFDemo
//
//  Created by leoo on 2021/8/11.
//

#import "AIFXMLParser.h"

NSString *const kXMLReaderTextNodeKey = @"text";

@interface AIFXMLParser (Internal)

- (id)initWithError:(NSError **)error;
- (NSDictionary *)objectWithData:(NSData *)data;

@end

@implementation AIFXMLParser
{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    NSError *errorPointer;
}
#pragma mark - Public methods

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error
{
    AIFXMLParser *reader = [[AIFXMLParser alloc] initWithError:error];
    NSDictionary *rootDictionary = [reader objectWithData:data];
    return rootDictionary;
}

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)error
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [AIFXMLParser dictionaryForXMLData:data error:error];
}

#pragma mark - Parsing

- (id)initWithError:(NSError **)error
{
    if (self = [super init])
    {
        errorPointer = *error;
    }
    return self;
}

- (void)dealloc
{
    
}

- (NSDictionary *)objectWithData:(NSData *)data
{
    // Clear out any old data
    dictionaryStack = [[NSMutableArray alloc] init];
    textInProgress = [[NSMutableString alloc] init];
    
    // Initialize the stack with a fresh dictionary
    [dictionaryStack addObject:[NSMutableDictionary dictionary]];
    
    // Parse the XML
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate =  self;
    BOOL success = [parser parse];
    
    // Return the stack’s root dictionary on success
    if (success)
    {
        NSDictionary *resultDict = [dictionaryStack objectAtIndex:0];
        return resultDict;
    }
    
    return nil;
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // Get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [dictionaryStack lastObject];
    
    // Create the child dictionary for the new element, and initilaize it with the attributes
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue)
    {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]])
        {
            array = (NSMutableArray *) existingValue;
        }
        else
        {
            array = [NSMutableArray array];
            [array addObject:existingValue];
            
            [parentDict setObject:array forKey:elementName];
        }
        
        [array addObject:childDict];
    }
    else
    {
        [parentDict setObject:childDict forKey:elementName];
    }
    
    [dictionaryStack addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSMutableDictionary *dictInProgress = [dictionaryStack lastObject];
    
    if ([textInProgress length] > 0)
    {
        [dictInProgress setObject:textInProgress forKey:kXMLReaderTextNodeKey];
        
        textInProgress = [[NSMutableString alloc] init];
    }
    
    [dictionaryStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [textInProgress appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    errorPointer = parseError;
}

@end


