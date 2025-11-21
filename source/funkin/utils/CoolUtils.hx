package funkin.utils;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import funkin.backend.MusicBeatSprite;

final class CoolUtils
{
    public static function loadAnimationFile(sprite:MusicBeatSprite, type:AnimationBaseFile, 
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
        sprite.animation.play(sprite.animation.getNameList()[0]);
        sprite.scale.copyFrom(scale);
    }

    public static function getAnimationURLS(data:AnimationBaseFile):Map<String, String>
    {
        final urls:Map<String, String> = [];
        for (url in data.urls)
        {
            urls[url.id] = url.path;
        }
        return urls;
    }
}