martinafong
Here is the programming challenge we would wish you to solve: Create a 1-minute delayed feed of the USD/JPY.

To do this, please do the following:

1. Connect to the Binary.com Websockets API to retrieve a live data feed of the USD/JPY exchange rate.
2. For every new tick that comes in, print (1) that tick, and (2) the tick that occurred 1 minute before.

Instructions:
1. To access the API, please view https://developers.binary.com
2. You may use any programming language of your choice.
3. Please try to complete your work within 90 minutes.
4. Feel free to ask questions using this chat box.



var ws = new WebSocket('wss://ws.binaryws.com/websockets/v3');

ws.onopen = function(evt) {
    ws.send(JSON.stringify({ticks:'R_100'}));
};

ws.onmessage = function(msg) {
   var data = JSON.parse(msg.data);
   console.log('ticks update: %o', data);
};
