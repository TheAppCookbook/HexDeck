// MARK: Imports
var WebSocketServer = require("ws").Server
var http = require("http")
var express = require("express")
var game = require("./models/game.js")

// MARK: Properties
var app = express()
var port = process.env.PORT || 5000
var currentGame = new game.Game()

// MARK: Initialization
app.use(express.static(__dirname + "/"))

var server = http.createServer(app)
server.listen(port)
console.log("http server listening on %d", port)

var socketServer = new WebSocketServer({server: server})
console.log("websocket server created")

// MARK: Message Handlers
socketServer.sockets = []
socketServer.broadcast = function(msg) {
    socketServer.sockets.forEach(function(_socket) {
        _socket.send(msg)
    })
}

// MARK: Connection Handler
socketServer.on("connection", function(socket) {
    // MARK: Connection Response
    console.log("connection open")
    socketServer.sockets.push(socket)
    socket.send(JSON.stringify({
        event: "connection",
        game_id: currentGame.id,
        current_card: currentGame.currentCard
    }))
    
    // MARK: Event Responders
    socket.on("message", function(data) {
        console.log("message")
    
        eventInfo = JSON.parse(data)
        if (eventInfo.event == "drag_started") {
            console.log("drag started ", currentGame.currentCard)
            socketServer.broadcast(JSON.stringify({
                event: "drag_started",
                player_id: eventInfo.player_id,
                location: eventInfo.location
            }))
        }
        
        else if (eventInfo.event == "drag_canceled") {
            console.log("drag canceled ", currentGame.currentCard)
            socketServer.broadcast(JSON.stringify({
                event: "drag_canceled",
                player_id: eventInfo.player_id
            }))
        }
        
        else if (eventInfo.event == "drag_completed") {
            console.log("drag completed ", currentGame.currentCard)
            
            eventInfo.card_index = currentGame.currentCard
            currentGame.handleDrag(eventInfo, function(game) {
                console.log("drag was successful ", game.currentCard)
                socketServer.broadcast(JSON.stringify({
                    event: "card_taken",
                    player_id: eventInfo.player_id,
                    current_card: game.currentCard
                }))
                
                if (game.onLastCard()) {
                    game.currentCard = 0
                    socketServer.broadcast(JSON.stringify({
                        event: "game_over"
                    }))
                }
            }, function (game) {
                console.log("drag collided ", game.currentCard)
                socketServer.broadcast(JSON.stringify({
                    event: "card_collided",
                    current_card: game.currentCard
                }))
            })
        }
    })
    
    socket.on("close", function() {
        socketServer.sockets = socketServer.sockets.filter(function (_socket) {
            return _socket != socket
        })
        
        console.log("closed")
    })
})
