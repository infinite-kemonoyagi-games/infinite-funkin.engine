package funkin.utils;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxXmlAsset;
import funkin.backend.MusicBeatSprite;
import haxe.xml.Access;

using StringTools;

final class CoolUtils
{
    public static final lowerCases:String = "abcdefghijklmnopqrstuvwxyz";
    public static final upperCases:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	public static final numbers:String = "1234567890";
	public static final symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?×←↓↑→☺☹😠😡♥♡❤";

    public static final characters:String = lowerCases + upperCases + numbers + symbols;

    public static function loadAnimationFile(sprite:MusicBeatSprite, type:AnimationTypeFile, 
        file:AnimationFile, urls:Map<String, String>, scale:FlxPoint):Void
    {
        final frame:FlxGraphicAsset = urls[file.path];
        switch type.id
        {
            case "default":
                final tex = FlxTileFrames.fromGraphic(frame, FlxPoint.get(file.size.x, file.size.y));
                sprite.getComplexAnim().createFrame(file.path, tex);
                sprite.getComplexAnim().setAnimToFrame(file.name, file.path);

                sprite.getComplexAnim().add(file.name, file.frames, file.framerate, file.looped, 
                    file.flip.x, file.flip.y);
                sprite.getComplexAnim().setOffsets(file.name, file.offsets.x, 
                    file.offsets.y, file?.centerOffsets ?? false);
            case "sparrow":
                final tex = FlxAtlasFrames.fromSparrow(frame + ".png", frame + ".xml");
                tex.parent.persist = true;
                sprite.getComplexAnim().createFrame(file.path, tex);
                sprite.getComplexAnim().setAnimToFrame(file.name, file.path);

                if (file.frames == null)
                {
                    sprite.getComplexAnim().addByPrefix(file.name, file.prefix, 
                        file.framerate, file.looped, file.flip.x, file.flip.y);
                }
                else
                {
                    sprite.getComplexAnim().addByIndices(file.name, file.prefix, file.frames, 
                        "", file.framerate, file.looped, file.flip.x, file.flip.y);
                }
                sprite.getComplexAnim().setOffsets(file.name, file.offsets.x, 
                    file.offsets.y, file?.centerOffsets ?? false);
        }
        sprite.scale.copyFrom(scale);
    }

    public static function getAnimationURLS(data:AnimationTypeFile):Map<String, String>
    {
        final urls:Map<String, String> = [];
        for (url in data.urls)
        {
            urls[url.id] = url.path;
        }
        return urls;
    }

    private static final cachedXML:Map<FlxXmlAsset, Access> = [];

    public static function existsAnimation(xml:FlxXmlAsset, animation:String):Bool
    {
		if (xml == null || xml == "") return false;

		var data:Access;
        if (cachedXML.exists(xml)) 
        {
            data = cachedXML.get(xml);
        }
        else 
        {
            data = new Access(xml.getXml().firstElement());
            cachedXML.set(xml, data);
        }

		for (texture in data.nodes.SubTexture)
		{
			if (!texture.has.width && texture.has.w)
				throw "Sparrow v1 is not supported, use Sparrow v2";
			
			var name = texture.att.name;
            if (name.startsWith(animation + "0")) return true;
		}

        return false;
    }
}