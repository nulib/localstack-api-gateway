function wait(seconds) {
  return new Promise((resolve, reject) => {
    setTimeout(() => { resolve(new Date()) }, seconds * 1000);
  });
};

function extractSeconds(event) {
  if (event?.params?.path?.seconds) {
    console.log('Event was transformed.')
    return Number(event.params.path.seconds);
  } else {
    console.log('Event was not transformed.')
    return Number(event.pathParameters .seconds);
  }
}

exports.handler = async (event, context) => {
  const start = new Date()
  console.log("Invoked at", start);
  const seconds = extractSeconds(event);
  console.log("Resolving in", seconds, "seconds");
  const result = await wait(seconds);
  console.log("Resolved at", result);

  const responsePayload = JSON.stringify({
    start: start, 
    end: result.toISOString(),
    event: event
  });

  console.log('Response:', responsePayload)

  return { 
    statusCode: 200, 
    body: responsePayload
  };
};
