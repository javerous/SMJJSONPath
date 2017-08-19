

SMJJSONPath
===========

SMJJSONPath is a complete JSONPath implementation written in Objective-C. It's a wide adaptation of [`Jayway JsonPath`](https://github.com/json-path/JsonPath) implementation.


## Overview

It supports a wide bunch of functionalities:
- dot and square bracket syntax
- inline predicates
- functions
- nesting

You can take a look to the `Jayway JsonPath` documentation for more information.


## Adaptation

This implementation is a tight  adaptation of `Jayway JsonPath`. It respects the original structure and naming, as much as possible. The changes are mainly to be more Objective-C stylized (named parameters, use NSError instead of try-catch-exception, etc.).

This tight adaptation was done for different reasons:
- If I wanted to structure something from my own view, I would have started from scratch, and I wouldn't have done it at all : this is a big bunch of code, tests and reflexion to do, more than I want to give to that.
- The `Jayway JsonPath` project have a pretty good and complete implementation (with some cleaning here and there to do, which are already documented by original developers). It's a good reference, from my point of view.
- I want to facilitate cherry-picking updates from `Jayway JsonPath` to include them right here.

This code is currently based on commit [c187488](https://github.com/json-path/JsonPath/commit/c1874886c1f69fada6dedccebb6d72241dcd0c97).

## Query

Simple example:

```
// Create a SMJJSONPath object
SMJJSONPath *jsonPath = [[SMJJSONPath alloc] initWithJSONPathString:@"$.books..author" error:&error];

// Create a configuration.
SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];

// Query a JSON document.
NSArray *result = [jsonPath resultForJSONFile:fileURL configuration:configuration error:&error];

// That's all.
```


## Update

You can update a JSON mutable object accordingly to a JSONPath:

```
// Create a SMJJSONPath object
SMJJSONPath *jsonPath = [[SMJJSONPath alloc] initWithJSONPathString:@"$.books..author" error:&error];

// Create a configuration.
SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];

// Read a JSON document with mutable containers.
id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

// Update the json.
[jsonPath updateJSONMutableObject:jsonObject deleteWithConfiguration:[SMJConfiguration defaultConfiguration] error:&error];


// The queried path was deleted in jsonObject.
```
