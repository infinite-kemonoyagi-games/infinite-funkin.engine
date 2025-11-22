package funkin.play.ui;

import flixel.FlxSprite;

class Rating extends FlxSprite
{
    public var skin:String = "";

    public function new(skin:String)
    {
        this.skin = skin;

        super();
    }

    public function loadRating(rating:String):Void 
    {
        rating = rating.toLowerCase();
        final URL:String = 'assets/images/ui/$skin/$rating.png';
        scale.set(0.7, 0.7);
        loadGraphic(URL);
    }
}