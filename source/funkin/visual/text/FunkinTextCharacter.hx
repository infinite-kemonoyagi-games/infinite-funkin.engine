package funkin.visual.text;

import funkin.assets.Paths;
import funkin.backend.MusicBeatSprite;
import funkin.utils.CoolUtils;

using StringTools;

class FunkinTextCharacter extends MusicBeatSprite
{
    private static var forceLowercase:Map<String, Bool> = [];

    public var parent:Null<FunkinText> = null;

    public var character:String;
    public var font:String;
    public var size:Float;
    public var row:Int;
    public var lastCharacter(default, null):Null<FunkinTextCharacter> = null;
    public var lastSpaces:Float = 0.0;
    public var lastRows:Int = 0;

    public var fileUrl:String;

    private var originalFont:String = "";

    public var originalPoints:Array<String> = null;
    public var referencePoints:Array<String> = null;

    public function new()
    {
        super();
    }

    public function setData(character:String, font:String, size:Float, row:Int = 0, 
        lastCharacter:FunkinTextCharacter):FunkinTextCharacter
    {
        this.character = character;
        this.font = font;
        this.size = size;
        this.row = row;
        this.lastCharacter = lastCharacter;

        fileUrl = Paths.images("fonts/" + font);
        final originalUrl = Paths.images("fonts/" + originalFont);

        if (originalFont != null && originalFont != "") 
            originalPoints = load.file(originalUrl + '-reference.txt').split(" ");
        referencePoints = load.file(fileUrl + '-reference.txt').split(" ");

        return this;
    }

    public function loadFont(?font:String = null):Void
    {
        if (font != null) this.font = font;

        frames = load.sparrowAtlas(fileUrl, true);

        function addAnimByChar(character:String):Void
        {
            final realCharacter:String = character;
            character = animCharName(character);
            animation.addByPrefix(realCharacter, character, 24, true);
        }
        function detectCharacter(character:String) 
        {
            if (CoolUtils.existsAnimation(fileUrl + ".xml", FunkinTextCharacter.animCharName(character)))
            {
                addAnimByChar(character);
            }
            else if (CoolUtils.lowerCases.contains(character))
            {
                animation.addByPrefix(character, character.toUpperCase(), 24, true);
                forceLowercase[this.font] = true;
            }
            else if (CoolUtils.upperCases.contains(character))
            {
                animation.addByPrefix(character, character.toLowerCase(), 24, true);
            }
            else if (this.font == "default")
            {
                animation.addByPrefix(character, '-question mark-', 24, true); // ?
            }
        }

        for (character in CoolUtils.characters.split("")) detectCharacter(character);
    }

    public function loadSimple(?Font:String = null):Void
    {
        if (Font != null) this.font = Font;
        frames = load.sparrowAtlas(fileUrl, true);
    }

    public function refreshChar(?noExists:() -> Void):Void
    {
        if (!animation.exists(character) && noExists != null) 
        {
            noExists();
            return;
        }

        animation.play(character);
        scale.set(size, size);
        var mult:Float = 1.0;
        if (CoolUtils.lowerCases.contains(character) && forceLowercase[font]) 
        {
            mult = 0.9;
            // scale.x *= mult;
            scale.y *= mult;
        }
        updateHitbox();

        function setOffset(isNotOriginal:Bool = false):Void
        {
            var oH:Float = 0.0;
            if (isNotOriginal) oH = Std.parseFloat(originalPoints[1]) * size;
            var rH:Float = Std.parseFloat(referencePoints[1]) * size;
            setGraphicSize(width, Math.min(height, rH));
            updateHitbox();
            final centerY:Float = switch character 
            {
                case "_" | "." | ",": height - (rH - oH);
                case "\'" | "\"": 0;
                default: (height - (rH - oH)) / 2;
            };
            offset.y += centerY;
        }
        if (referencePoints != null) setOffset(originalPoints != null);
    }

    public function copyFrom(character:FunkinTextCharacter):FunkinTextCharacter
    {
        setData(character.character, character.font, character.size, character.row, character.lastCharacter);
        frames = character.frames;
        animation.copyFrom(character.animation);
        return this;
    }

    public static function cloneFrom(character:FunkinTextCharacter):FunkinTextCharacter
    {
        final text:FunkinTextCharacter = new FunkinTextCharacter();
        text.copyFrom(character);
        return text;
    }

    public static function animCharName(?char:String):String
    {
        return switch char
        {
            case "-": "-dash-";
            case "\'": "-apostraphie-";
            case "\"": "-apostraphie-";
            case "\\": "-black slash-";
            case ",": "-comma-";
            case "!": "-explamation point-";
            case "/": "-forward slash-";
            case ".": "-period-";
            case "?": "-question mark-";
            case "_": "-start quote-";

            case "×": "-multiply x-";
            case "←": "-left arrow-";
            case "↓": "-down arrow-";
            case "↑": "-up arrow-";
            case "→": "-right arrow-";
            case "☺" | "☹" | "😠" | "😡": "-angry faic-";
            case "♥" | "♡" | "❤": "-heart-";

            default: char;
        };
    }
}