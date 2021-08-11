# AIFXMLParser
简单高效的XML文档解析器
```
//示例
NSError *error = nil;

NSDictionary *XMLDict = [AIFXMLParser dictionaryForXMLData: XMLdata error:&error];

NSDictionary *XMLDict = [AIFXMLParser dictionaryForXMLString: XMLStr error:&error];
```
