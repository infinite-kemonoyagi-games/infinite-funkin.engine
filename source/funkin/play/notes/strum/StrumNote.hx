package funkin.play.notes.strum;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import funkin.backend.MusicBeatSprite;
import funkin.play.notes.data.NoteFile;

class StrumNote extends MusicBeatSprite
{
    public var name:String;
    public var data:NoteData;

    public function new(data:NoteData, file:NoteFile)
    {
        super();

        final urls:Map<String, String> = [];
        for (url in file.spriteType.urls)
        {
            urls[url.id] = url.path;
        }

        name = data.note;
        for (anim in data.animations)
        {
            final frame:FlxGraphicAsset = urls[anim.path];
            switch file.spriteType.id
            {
                case "default":
                    getComplexAnimation().createFrame(anim.path, 
                        FlxTileFrames.fromGraphic(frame, FlxPoint.get(anim.size.x, anim.size.y)));
                    getComplexAnimation().setAnimToFrame(anim.name, anim.path);

                    getComplexAnimation().add(anim.name, anim.frames, anim.framerate, anim.looped, 
                        anim.flip.x, anim.flip.y);
                    getComplexAnimation().setOffsets(anim.name, anim.offsets.x, 
                        anim.offsets.y, anim?.centerOffsets ?? false);
                case "sparrow":
                    getComplexAnimation().createFrame(anim.path, 
                        FlxAtlasFrames.fromSparrow(frame + ".png", frame + ".xml"));
                    getComplexAnimation().setAnimToFrame(anim.name, anim.path);

                    if (anim.frames != null)
                    {
                        getComplexAnimation().addByPrefix(anim.name, anim.prefix, 
                            anim.framerate, anim.looped, anim.flip.x, anim.flip.y);
                    }
                    else
                    {
                        getComplexAnimation().addByIndices(anim.name, anim.prefix, anim.frames, 
                            "", anim.framerate, anim.looped, anim.flip.x, anim.flip.y);
                    }
                    getComplexAnimation().setOffsets(anim.name, anim.offsets.x, 
                        anim.offsets.y, anim?.centerOffsets ?? false);
            }
        }
        animation.play(animation.getNameList()[0]);
    }
}
