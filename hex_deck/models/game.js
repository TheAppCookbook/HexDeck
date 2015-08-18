var uuid = require("uuid")
var exports = module.exports = {};

exports.Game = function() {
    this.id = uuid.v4()
    this.currentCard = 0x000000
    
    this.dragAttempts = {}
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
        var dragID = dragInfo.card_index + ''
        
        this.dragAttempts[dragID] = (this.dragAttempts[dragID] || new Set())
        this.dragAttempts[dragID].add(dragInfo.player_id)
    
        var self = this
        setTimeout(function() {
            console.log(self.dragAttempts)
            
            var dragAttempts = (self.dragAttempts[dragID] || new Set())
            delete self.dragAttempts[dragID]
            
            if (dragAttempts.size == 1) {
                self.currentCard = self.nextCard()
                success(self)
            } else if (dragAttempts.size > 1) {
                self.currentCard = 0x000000
                collision(self)
            }
        }, this.collisionWindow)
    }
}