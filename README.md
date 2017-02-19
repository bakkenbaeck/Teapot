
# Teapot
A light-weight URLSession wrapper for building simple API clients.

<img src="./teapot.png" width=257 height=200 />

Teapot consists of a only three simple structures: a JSON optional-like container, a NetworkResult container, and the Teapot itself, that acts as a nice thin wrapper around URLSession.

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

### Teapot itself
Our cutely named Teapot is the wrapper itself. It’s instantiated with a base URL and exposes four main methods: a `get`, a `post`, a `put`, and a `delete` method. It also has a stub `patch` method if your API interface requires it.

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
