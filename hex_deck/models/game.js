var uuid = require("uuid")
var exports = module.exports = {};

exports.Game = function() {
    this.id = uuid.v4()
    this.currentCard = 0x000000
    
    this.dragAttempts = 0 // assumes currentCard
    this.collisionWindow = 250 //ms
    
    this.previousCard = function() {
        return this.currentCard - 0x000001
    }
    
    this.nextCard = function() {
        return this.currentCard + 0x000001
    }
    
    this.onLastCard = function() {
        return this.currentCard >= 0xFFFFFF
    }
    
    this.handleDrag = function(dragInfo, success, collision) {
        this.dragAttempts += 1
    
        var self = this
        setTimeout(function() {
            var dragAttempts = self.dragAttempts         
            self.dragAttempts = 0
            
            if (dragAttempts == 1) {
                self.currentCard = self.nextCard()
                success(self)
            } else if (dragAttempts > 1) {
                self.currentCard = 0x000000
                collision(self)
            }
        }, this.collisionWindow)
    }
}