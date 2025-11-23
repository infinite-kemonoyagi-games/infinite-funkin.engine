package funkin.visual.text;

import funkin.assets.Paths;
import funkin.backend.MusicBeatSprite;
import funkin.utils.CoolUtils;

using StringTools;

class FunkinTextCharacter extends MusicBeatSprite
{
    public var parent:Null<FunkinText> = null;

    public var character:String;
    public var font:String;
    public var size:Int;
    public var row:Int;
    public var lastCharacter(default, null):Null<FunkinTextCharacter> = null;
    public var lastSpaces(default, null):Float = 0.0;
    public var lastRows(default, null):Int = 0;

    private var forceLowercase:Bool = false;

    public var fileUrl:String;

    private var originalFont:String = "";

    public var originalPoints:Array<String> = null;
    public var referencePoints:Array<String> = null;

    public function new()
    {
        super();
    }

    public function setData(character:String, font:String, size:Int, row:Int = 0, lastCharacter:FunkinTextCharacter):FunkinTextCharacter
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

        load.sparrowAtlas(fileUrl, true);

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
                forceLowercase = true;
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

        for (character in CoolUtils.characters.split("")) 
        {
            detectCharacter(character);
        }
    }

    public function loadSimple(?Font:String = null):Void
    {
        if (Font != null) this.font = Font;
        load.sparrowAtlas(fileUrl, true);
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
        updateHitbox();

        function setOffset(isNotOriginal:Bool = false):Void
        {
            var oH:Float = 0.0;
            if (isNotOriginal)
            {
                oH = Std.parseFloat(originalPoints[1]) * size;
            }
            final rH:Float = Std.parseFloat(referencePoints[1]) * size;
            final centerY:Float = switch character 
            {
                case "_" | "." | ",": height - (rH - oH);
                case "\'" | "\"": 0;
                default: (height - (rH - oH)) / 2;
            };

            offset.y += centerY;
        }
        if (referencePoints != null)
        {
            setOffset(originalPoints != null);
        }
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