
# Teapot

[_**HTTP status code 418**: I'm a teapot._](https://tools.ietf.org/html/rfc2324)

A light-weight URLSession wrapper for building simple API clients.

<img src="./teapot.png" width=257 height=200 />

Teapot consists of three simple structures: a JSON optional-like container, a NetworkResult container, and the Teapot itself, that acts as a nice thin wrapper around URLSession.

### JSON
The `JSON` structure is simple enum with two cases: dictionary and array. The API is designed considering that the routing model should know if the JSON will be a dictionary or an array, but also to accommodate for cases where they won’t.

```swift
// We know this API endpoint always returns a dictionary
guard let json = json?.dictionary else { return }

// Here we can have both:
switch json {
case .dictionary(let dict):
    // Handle dictionary case
case .array(let ary):
    // handle array case
}
```

### NetworkResult
The `NetworkResult` is responsible for encapsulating the success/failure of our API request and providing us with the relevant objects for either case.

```swift
self.teapot.get("path") { result in
    switch result {
    case .success(let json, let response):
        // handle success case, JSON is an optional
        if response.status == 204 {
            // no content
        }
    case .failure(let json, let response, let error):
        // handle failure case. json is an optional.
    }
}
```

### Basic Auth
We have support for basic authorisation as well. Check `Teapot+BasicAuth.swift` for more details on what we provide and expose.

You can get just the basic auth key string:
```swift
// "Basic YWRtaW46dGVzdDEyMw=="
let basicAuthString = teapot.basicAuthenticationValue(username: "", password: "")
```

Or the complete header:
```swift
// ["Authorization": "Basic YWRtaW46dGVzdDEyMw=="]
let basicAuthHeader = teapot.basicAuthenticationHeader(username:  "", password: "")
```

### Teapot itself
Our cutely named Teapot is the wrapper itself. It’s instantiated with a base URL and exposes four main methods: a `get`, a `post`, a `put`, and a `delete` method.

### Example API client

```swift
class APIClient {
    var teapot: Teapot
    init(baseURL: URL) {
        self.teapot = Teapot(baseURL: baseURL)
    }
    
    func getSomething() {
        self.teapot.get("something") { result in
            // handle success, failure, etc
        }
    }
    
    func postSomething(params: [String: Any]) {
        self.teapot.post("something", parameters: params, allowsCellular: false) { result in 
            // handle result
        }
    }
}
```

### Cancelling, suspending, resuming, and so on…

Each of the verb methods return an optional `URLSessionTask` object (it will only be nil if the request path is invalid). 

```swift
    let task = teapot.get("/path/here") { }
    // something changed and we need to wait
    task?.suspend()
    // user decided to cancel the operation completely, or resume
    if cancelOperation {
        task?.cancel()
    } else {
        task?.resume()
     }
```


### Error handling

The struct `TeapotError` conforms to `LocalizedError` and handles the following cases:

1. Invalid request path: The path provided contains characters or a format that can't be resolved by `URLComponents`.
2. Invalid response status. Status is not between 200 and 299, and is therefore treated as an error by Teapot (not necessarily by your Application, however).
3. Image is missing. When using Teapot to download an image, if the result is nil.

`TeapotError` also provides a simple yet descriptive error description. 

#### Localising error strings

By default, we use Teapot's own `.strings` file:

```
"Teapot:InvalidRequestPath" = "An error occurred: request URL path is invalid.";
"Teapot:MissingImage" = "An error occurred: image is missing.";
"Teapot:InvalidResponseStatus" = "An error occurred: request response status reported an issue. Status code: %d.";
```

You can replace it with your own file, implementing those keys and set it globally with:

```swift
Teapot.localizationBundle = Bundle.myAppBundle
```

## Mocking 

To mock network calls for testing, you can use a `MockTeapot` instead of a standard `Teapot`. This allows you to return the contents of a file when the `MockTeapot` instance is next used. For example: 

```swift
let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), 
							  mockFilename: "get")
```

Will look in the test bundle for a file named `get.json`, and then return its contents whenever the next method is called on the `MockTeapot`: 

```swift
mockedTeapot.get("/get") { result in
	// result will be `.success` and the contents of `get.json` are returned
}
```

You can also specify the status code you wish to receive back from the `MockTeapot`. This is useful for testing error handling: 

```swift
let mockedFailingTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), 
                                     mockFilename: "get", 
                                     statusCode: .unauthorized)
                                     
mockedFailingTeapot.get("/get") { result in
     // Result will be `.failure` and the response status code will be 401 Unauthorized
}
```

### Overriding Specified Endpoints With A Mock

Occasionally, you will need to hit an endpoint such as retrieving a timestamp or an `XSRF` token prior to making your actual call. 

Here is an example of an API which uses a `Teapot` instance to do something like this: 

```swift 
class API {
 
    static var currentTeapot: Teapot!

    private static func getTimestamp(completion: (_ timestamp: Int?, error: TeapotError?) -> Void) {
		currentTeapot.get("/timestamp") { result in 
			switch result {
			case .success(let _, response): 
				guard let timestamp = /* something from the response */ else {
					let timestampParseError = TeapotError(type: .invalidMockFile, 
					                					  description: "Error parsing timestamp",
					                					  responseStatus: response.statusCode, 
					                					  underlyingError: nil)
					completion(nil, timestampParseError)
					return
				}
				
				completion(timestamp, nil)
			case .failure(let _, _, error):
				let timestampFetchError = TeapotError(type: error.type,
				                                      description: "Error fetching timestamp",
				                                      responseStatus: error.responseStatus,
				                                      underlyingError: error)
				completion(nil, timestampFetchError) 
			}
		}
    } 
    
    static func fetchSecureString(completion: (_ secureString: String?, error: TeapotError?) -> Void) {
		getTimestamp { timestamp, error in 
			guard let timestamp = timestamp else {
    			completion (nil, error)
    			return 
    		}    		
   			let headers = [ "Timestamp" : timestamp ]
			currentTeapot.get("/something_secure", headerFields: headers) { result in 
				switch result {
				case .success(let _, response) { 
					guard let secureString = /* something from the response */ else {
						let stringParseError = TeapotError(type: .invalidMockFile,
						                                   description: "Error parsing secure string",
						                                   responseStatus: response.statusCode,
						                                   underlyingError: nil)
						completion(nil, stringParseError)
						return 
					}
					completion(secureString, nil)
				case .failure(let _, _, error): {
					let stringFetchError = TeapotError(type: error.type,
							    					   description: "Error fetching secure string",
							    					   responseStatus: error.responseStatus,
							    					   underlyingError: error)
					completion(nil, stringFetchError)
				}
			}
		}
    }
}
```

If you wanted to write a test of this API, you'd want to write something like: 

```swift
func testGettingSecureString() {
	let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), 
								  mockFilename: "something_secure")
	API.teapot = mockedTeapot
	
	API.fetchSecureString { secureString, error in 
		XCTAssertNil(error)
		XCTAssertNotNil(secureString)
		XCTAssertEqual(secureString, "expected secure string")
	}
}
```

However, without any changes, this would cause the `timestamp` endpoint to return the contents of `something_secure.json`. This is not what you want, since that would cause an error in the underlying `getTimestamp` method, causing your test to fail. 

This is where overriding comes in - you can specify that data can be returned for a particular endpoint which is not the direct thing being called by your API. Here, the same test is updated to include an override on the `timestamp` endpoint:

```swift
func testGettingSecureString() {
	let mockedOverriddenTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), 
								 			mockFilename: "something_secure")
	// Tell the mock teapot to return a particular file for a particular endpoint
	mockedOverriddenTeapot.overrideEndPoint("timestamp", withFilename: "timestamp")	
	API.teapot = mockedOverriddenTeapot
	
	API.fetchSecureString { secureString, error in 
		XCTAssertNil(error)
		XCTAssertNotNil(secureString)
		XCTAssertEqual(secureString, "expected secure string")
	}
}
```

Now, your test will be passing or failing based on what's happening in the bulk of `getSecureString` rather than just the `getTimestamp` bit. 

Note: If you specify both an overridden endpoint and a failure status, that failure status will not be applied to the endpoint you overrode. 

```swift
func testUnauthorizedTryingToGetSecureString() {
	let mockedOverriddenFailingTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), 
				  								   mockFilename: "something_secure",
				  								   statusCode: .unauthorized)
	// Tell the mock teapot to return a particular file for a particular endpoint
	mockedOverriddenTeapot.overrideEndPoint("timestamp", withFilename: "timestamp")	
	API.teapot = mockedOverriddenTeapot

	API.fetchSecureString { secureString, error in 
		XCTAssertNil(secureString)
		XCTAssertNotNil(error)
		XCTAssertEqual(error?.description, "Error fetching secure string")
		XCTAssertEqual(error?.responseStatus, 401)
	}
}
```

This allows you to make sure the failure is actually going through the main error handling in `fetchSecureString` rather than just dying as soon as the `timestamp` endpoint is hit. 

You can also validate that certain headers are present and match what they are expected to be. This is useful if you need to provide signatures in your headers and want to make sure they're there without needing to hit a live API. 

To add headers to check for: 

```swift
teapot.setExpectedHeaders([
    "foo": "bar",
    "baz": "foo2",
])
```

Then, when the next method is called on the teapot, it will validate that header fields for both expected headers are there and have the appropriate value.

Note: This does not check that these are the **only** headers included, but that at **least** these headers are included. 

