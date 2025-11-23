package funkin.visual.text;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxPool;

class FunkinText extends FlxTypedSpriteGroup<FunkinTextCharacter>
{
    public static var templates:Map<String, FunkinTextCharacter> = [];
    public static var pool(default, null):FlxPool<FunkinTextCharacter> = new FlxPool<FunkinTextCharacter>(function()
    {
        return new FunkinTextCharacter();
    });

    public var text(default, set):String;
    public var font(default, set):String;
    public var size:Float = 0;
    public var spaceLength:Float = 1.0;
    public var rowSize:Float = 1.0;

    public var individualAngle:Float = 0.0;

    public function new(text:String = "", size:Float = 1.0, font:String = "default")
    {
        super();

        this.size = size;
        this.font = font;
        this.text = text;
    }

    private function generateText(text:String, font:String):Void
    {
        if (text == "" || text == null) return;
        final textSplitted:Array<String> = text.split("\n");
        var lastCharacter:FunkinTextCharacter = null;
        var voidRows:Int = 0;
        for (rowIndex => rowValue in textSplitted) 
        {
            final characters:Array<String> = rowValue.split("");
            var spaces:Int = 0;
            if (rowValue == "")
            {
                ++voidRows;
                continue;
            }
            spaces = 0;
            for (index => character in characters)
            {
                if (character == " ") 
                {
                    ++spaces;
                    continue;
                }
                var sprite:FunkinTextCharacter = null;
                function createCharacter(daFont:String):Void
                {
                    sprite = FunkinText.getTemplate(daFont);
                    sprite.parent = this;
                    sprite.setData(character, daFont, size, rowIndex, lastCharacter);
                    sprite.ID = index;
                }
                createCharacter(font);
                add(sprite); // add the sprite before of update the position
                sprite.lastSpaces = spaces;
                sprite.lastRows = voidRows;
                sprite.refreshChar(() -> 
                {
                    if (sprite.font == "default") return;
                    createCharacter("default");
                    @:privateAccess
                    sprite.originalFont = font;
                    sprite.refreshChar();
                });
                if (lastCharacter != null) sprite.x = lastCharacter.x + lastCharacter.width;
                sprite.x += 40 * spaces * size;
                sprite.x *= spaceLength;
                sprite.y = 40 * size * rowIndex * rowSize;
                spaces = 0;
                lastCharacter = sprite;
            }
            lastCharacter = null;
            if (voidRows > 0) voidRows = 0;
            ++voidRows;
        }
    }

    @:noCompletion
    function set_text(newValue:String):String
    {
        if (text == newValue || newValue == "") return text;
        generateText(newValue, font);
        return text = newValue;
    }

    @:noCompletion
    function set_font(newValue:String):String
    {
        if (font == newValue || newValue == "") return font;
        if (!templates.exists(newValue)) loadFont(newValue);
        generateText(text, newValue);
        return font = newValue;
    }

    public static function loadFont(font:String):Void 
    {
        if (templates.exists(font)) return;

        final character:FunkinTextCharacter = new FunkinTextCharacter();
        character.setData("A", font, 16, 0, null);
        character.loadFont();
        templates.set(font, character);
    }

    public static function getTemplate(font:String):FunkinTextCharacter 
    {
        var char:FunkinTextCharacter = pool.get();
        var template:FunkinTextCharacter = templates.get(font);
        if (template != null) char.copyFrom(template);
        return char;
    }

    @:allow(Main)
    private inline static function loadDefaultFont():Void loadFont("default");
}