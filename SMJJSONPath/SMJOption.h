/*
 * SMJOption.h
 *
 * Copyright 2020 Avérous Julien-Pierre
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/Option.java */


/*
** Types
*/
#pragma mark - Types

typedef enum SMJOption {
	
	/**
	 * returns <code>null</code> for missing leaf.
	 *
	 * <pre>
	 * [
	 *      {
	 *         "foo" : "foo1",
	 *         "bar" : "bar1"
	 *      }
	 *      {
	 *         "foo" : "foo2"
	 *      }
	 * ]
	 *</pre>
	 *
	 * the path :
	 *
	 * "$[*].bar"
	 *
	 * Without flag ["bar1"] is returned
	 * With flag ["bar1", null] is returned
	 *
	 *
	 */
	SMJOptionDefaultPathLeafToNull,
	
	/**
	 * Makes this implementation more compliant to the Goessner spec. All results are returned as Lists.
	 */
	SMJOptionAlwaysReturnList,
	
	/**
	 * Returns a list of path strings representing the path of the evaluation hits
	 */
	SMJOptionAsPathList,
	
	/**
	 * Configures JsonPath to require properties defined in path when an <bold>indefinite</bold> path is evaluated.
	 *
	 *
	 * Given:
	 *
	 * <pre>
	 * [
	 *     {
	 *         "a" : "a-val",
	 *         "b" : "b-val"
	 *     },
	 *     {
	 *         "a" : "a-val",
	 *     }
	 * ]
	 * </pre>
	 *
	 * evaluating the path "$[*].b"
	 *
	 * If SMJOptionRequireProperties option is present PathNotFoundException is thrown.
	 * If SMJOptionRequireProperties option is not present ["b-val"] is returned.
	 */
	SMJOptionRequireProperties
} SMJOption;
