## Description

This repository demonstrates some discrepancies between how AWS and LocalStack API Gateway V1 REST APIs handle certain integration features.

## Setup

### Deploy to LocalStack

```
$ cd tf_local
$ terraform init
$ terraform apply
```

### Deploy to AWS

```
$ cd tf_aws
$ terraform init
$ terraform apply
```

## Lambda Integration with Event InvocationType and Transformations

### AWS

#### Request

Returns immediately (0.110 seconds) and with an empty response, indicating asynchronous invocation
```
$ time curl https://API_ID.execute-api.us-east-1.amazonaws.com/latest/wait/3
curl https://API_ID.execute-api.us-east-1.amazonaws.com/latest/wait/3  0.01s user 0.01s system 18% cpu 0.110 total
```

#### Lambda Log

Indicates that the async Lambda actually did run for the full 3 seconds
```
START RequestId: 453ddc0e-ebc8-4a97-bf95-828ff54b96f8 Version: $LATEST
INFO	Invoked at 2022-04-12T21:23:32.679Z
INFO	Event was transformed.
INFO	Resolving in 3 seconds
INFO	Resolved at 2022-04-12T21:23:35.701Z
INFO	Response: {"start":"2022-04-12T21:23:32.679Z","end":"2022-04-12T21:23:35.701Z","event":{"params":{"path":{"seconds":"3"},"querystring":{},"header":{"Accept":"*/*","CloudFront-Forwarded-Proto":"https","CloudFront-Is-Desktop-Viewer":"true","CloudFront-Is-Mobile-Viewer":"false","CloudFront-Is-SmartTV-Viewer":"false","CloudFront-Is-Tablet-Viewer":"false","CloudFront-Viewer-Country":"US","Host":"API_ID.execute-api.us-east-1.amazonaws.com","User-Agent":"curl/7.79.1","Via":"2.0 977219f9fca056a953830ed07e32854e.cloudfront.net (CloudFront)","X-Amz-Cf-Id":"v8ETbdeaTJl-UHvwF7UY-y7j2B03H0zOc51ybGK5mPPAAC8kmow6uw==","X-Amzn-Trace-Id":"Root=1-6255edd4-2606567557477a4a30d2d1c9","X-Forwarded-For":"129.105.19.114, 130.176.168.140","X-Forwarded-Port":"443","X-Forwarded-Proto":"https"}}}}
END RequestId: 453ddc0e-ebc8-4a97-bf95-828ff54b96f8
REPORT RequestId: 453ddc0e-ebc8-4a97-bf95-828ff54b96f8	Duration: 3067.25 ms	Billed Duration: 3068 ms	Memory Size: 128 MB	Max Memory Used: 57 MB
```

#### Event Object (extracted from Lambda Log)

The event object includes only the integration request transform template result.
```
{
  "params": {
    "path": {
      "seconds": "3"
    },
    "querystring": {},
    "header": {
      "Accept": "*/*",
      "CloudFront-Forwarded-Proto": "https",
      "CloudFront-Is-Desktop-Viewer": "true",
      "CloudFront-Is-Mobile-Viewer": "false",
      "CloudFront-Is-SmartTV-Viewer": "false",
      "CloudFront-Is-Tablet-Viewer": "false",
      "CloudFront-Viewer-Country": "US",
      "Host": "API_ID.execute-api.us-east-1.amazonaws.com",
      "User-Agent": "curl/7.79.1",
      "Via": "2.0 977219f9fca056a953830ed07e32854e.cloudfront.net (CloudFront)",
      "X-Amz-Cf-Id": "v8ETbdeaTJl-UHvwF7UY-y7j2B03H0zOc51ybGK5mPPAAC8kmow6uw==",
      "X-Amzn-Trace-Id": "Root=1-6255edd4-2606567557477a4a30d2d1c9",
      "X-Forwarded-For": "129.105.19.114, 130.176.168.140",
      "X-Forwarded-Port": "443",
      "X-Forwarded-Proto": "https"
    }
  }
}
```

### LocalStack

#### Request

Returns in 3.170 seconds with full response, indicating synchronous invocation
```
$ time curl https://API_ID.execute-api.localhost.localstack.cloud:4566/latest/wait/3
{"start":"2022-04-12T21:25:55.150Z","end":"2022-04-12T21:25:58.163Z","event":{"path":"/wait/3","headers":{"Remote-Addr":"172.19.0.1","Host":"API_ID.execute-api.localhost.localstack.cloud:4566","User-Agent":"curl/7.79.1","accept":"*/*","X-Forwarded-For":"172.19.0.1, API_ID.execute-api.localhost.localstack.cloud:4566, 127.0.0.1, API_ID.execute-api.localhost.localstack.cloud:4566","x-localstack-edge":"https://API_ID.execute-api.localhost.localstack.cloud:4566","Authorization":"","x-localstack-tgt-api":"apigateway"},"multiValueHeaders":{"Remote-Addr":["172.19.0.1"],"Host":["API_ID.execute-api.localhost.localstack.cloud:4566"],"User-Agent":["curl/7.79.1"],"accept":["*/*"],"X-Forwarded-For":["172.19.0.1, API_ID.execute-api.localhost.localstack.cloud:4566, 127.0.0.1, API_ID.execute-api.localhost.localstack.cloud:4566"],"x-localstack-edge":["https://API_ID.execute-api.localhost.localstack.cloud:4566"],"Authorization":[""],"x-localstack-tgt-api":["apigateway"]},"body":"{\n  \"params\" : {\n    \n            \"path\" : {\n        \n          \"seconds\" : \"3\"\n                        }\n      ,    \n            \"querystring\" : {\n              }\n      ,    \n            \"header\" : {\n              }\n            }\n}\n","isBase64Encoded":false,"httpMethod":"GET","queryStringParameters":{},"multiValueQueryStringParameters":{},"pathParameters":{"seconds":"3"},"resource":"/wait/{seconds}","requestContext":{"accountId":"000000000000","apiId":"API_ID","resourcePath":"/wait/{seconds}","domainPrefix":"API_ID","domainName":"API_ID.execute-api.localhost.localstack.cloud","resourceId":"asf3naxvv6","requestId":"25419ac5-3748-4fbd-b48e-6f37bbc34d47","identity":{"accountId":"000000000000","sourceIp":"127.0.0.1","userAgent":"curl/7.79.1"},"httpMethod":"GET","protocol":"HTTP/1.1","requestTime":"12/Apr/2022:21:25:53 +0000","requestTimeEpoch":1649798753755,"authorizer":{},"path":"/latest/wait/3","stage":"latest"}}}
curl   0.01s user 0.01s system 0% cpu 3.170 total
```

#### Lambda Log
```
INFO	Invoked at 2022-04-12T21:25:55.150Z
INFO	Event was not transformed.
INFO	Resolving in 3 seconds
INFO	Resolved at 2022-04-12T21:25:58.163Z
INFO	Response: {"start":"2022-04-12T21:25:55.150Z","end":"2022-04-12T21:25:58.163Z","event":{"path":"/wait/3","headers":{"Remote-Addr":"172.19.0.1","Host":"API_ID.execute-api.localhost.localstack.cloud:4566","User-Agent":"curl/7.79.1","accept":"*/*","X-Forwarded-For":"172.19.0.1, API_ID.execute-api.localhost.localstack.cloud:4566, 127.0.0.1, API_ID.execute-api.localhost.localstack.cloud:4566","x-localstack-edge":"https://API_ID.execute-api.localhost.localstack.cloud:4566","Authorization":"","x-localstack-tgt-api":"apigateway"},"multiValueHeaders":{"Remote-Addr":["172.19.0.1"],"Host":["API_ID.execute-api.localhost.localstack.cloud:4566"],"User-Agent":["curl/7.79.1"],"accept":["*/*"],"X-Forwarded-For":["172.19.0.1, API_ID.execute-api.localhost.localstack.cloud:4566, 127.0.0.1, API_ID.execute-api.localhost.localstack.cloud:4566"],"x-localstack-edge":["https://API_ID.execute-api.localhost.localstack.cloud:4566"],"Authorization":[""],"x-localstack-tgt-api":["apigateway"]},"body":"{\n  \"params\" : {\n    \n            \"path\" : {\n        \n          \"seconds\" : \"3\"\n                        }\n      ,    \n            \"querystring\" : {\n              }\n      ,    \n            \"header\" : {\n              }\n            }\n}\n","isBase64Encoded":false,"httpMethod":"GET","queryStringParameters":{},"multiValueQueryStringParameters":{},"pathParameters":{"seconds":"3"},"resource":"/wait/{seconds}","requestContext":{"accountId":"000000000000","apiId":"API_ID","resourcePath":"/wait/{seconds}","domainPrefix":"API_ID","domainName":"API_ID.execute-api.localhost.localstack.cloud","resourceId":"asf3naxvv6","requestId":"25419ac5-3748-4fbd-b48e-6f37bbc34d47","identity":{"accountId":"000000000000","sourceIp":"127.0.0.1","userAgent":"curl/7.79.1"},"httpMethod":"GET","protocol":"HTTP/1.1","requestTime":"12/Apr/2022:21:25:53 +0000","requestTimeEpoch":1649798753755,"authorizer":{},"path":"/latest/wait/3","stage":"latest"}}}
```

#### Event Object (extracted from Lambda Log)

The event object includes the entire API Gateway request event, with the integration request transform template result included as a stringified JSON body.
```
{
  "path": "/wait/3",
  "headers": {
    "Remote-Addr": "172.19.0.1",
    "Host": "API_ID.execute-api.localhost.localstack.cloud:4566",
    "User-Agent": "curl/7.79.1",
    "accept": "*/*",
    "X-Forwarded-For": "172.19.0.1, API_ID.execute-api.localhost.localstack.cloud:4566, 127.0.0.1, API_ID.execute-api.localhost.localstack.cloud:4566",
    "x-localstack-edge": "https://API_ID.execute-api.localhost.localstack.cloud:4566",
    "Authorization": "",
    "x-localstack-tgt-api": "apigateway"
  },
  "multiValueHeaders": {
    "Remote-Addr": ["172.19.0.1"],
    "Host": ["API_ID.execute-api.localhost.localstack.cloud:4566"],
    "User-Agent": ["curl/7.79.1"],
    "accept": ["*/*"],
    "X-Forwarded-For": ["172.19.0.1, API_ID.execute-api.localhost.localstack.cloud:4566, 127.0.0.1, API_ID.execute-api.localhost.localstack.cloud:4566"],
    "x-localstack-edge": ["https://API_ID.execute-api.localhost.localstack.cloud:4566"],
    "Authorization": [""],
    "x-localstack-tgt-api": ["apigateway"]
  },
  "body": "{\\n  \\"
  params\\ " : {\\n    \\n            \\"
  path\\ " : {\\n        \\n          \\"
  seconds\\ " : \\"
  3\\ "\\n                        }\\n      ,    \\n            \\"
  querystring\\ " : {\\n              }\\n      ,    \\n            \\"
  header\\ " : {\\n              }\\n            }\\n}\\n",
  "isBase64Encoded": false,
  "httpMethod": "GET",
  "queryStringParameters": {},
  "multiValueQueryStringParameters": {},
  "pathParameters": {
    "seconds": "3"
  },
  "resource": "/wait/{seconds}",
  "requestContext": {
    "accountId": "000000000000",
    "apiId": "API_ID",
    "resourcePath": "/wait/{seconds}",
    "domainPrefix": "API_ID",
    "domainName": "API_ID.execute-api.localhost.localstack.cloud",
    "resourceId": "asf3naxvv6",
    "requestId": "25419ac5-3748-4fbd-b48e-6f37bbc34d47",
    "identity": {
      "accountId": "000000000000",
      "sourceIp": "127.0.0.1",
      "userAgent": "curl/7.79.1"
    },
    "httpMethod": "GET",
    "protocol": "HTTP/1.1",
    "requestTime": "12/Apr/2022:21:25:53 +0000",
    "requestTimeEpoch": 1649798753755,
    "authorizer": {},
    "path": "/latest/wait/3",
    "stage": "latest"
  }
}
```

## Mock Integration with Transformation

### AWS

```
$ curl https://API_ID.execute-api.us-east-1.amazonaws.com/latest/echo/sometext
{"echo": "sometext", "response": "mocked"}
```

### LocalStack

```
$ curl https://API_ID.execute-api.localhost.localstack.cloud:4566/latest/echo/sometext
{}
```
