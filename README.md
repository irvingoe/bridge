# bridge

def http = new HTTPBuilder(url)
def result = http.request(POST, JSON) { req ->
    body = inputData
    
    response.success = { resp ->
        String text = resp.entity.content.text
        String contentType = resp.headers."Content-Type"
        if (contentType?.startsWith("application/json")) {
            def json = JsonSlurper().parseText(text)
            ...
        }
        else {
            // return error
            ...
        }
    }
    response.failure = { resp ->
        ...
    }
}
