package funkin.assets;

import flixel.graphics.frames.FlxAtlasFrames;

class FunkinLoader
{
    private var parent:Null<FunkinAssets>;

    public function new(parent:FunkinAssets)
    {
        this.parent = parent;
    }

    public function image(dir:String, ?permanent:Bool = false):Null<Graphic>
    {
        if (parent == null) return null;

        if (parent.memory.hasImage(dir))
            return parent.memory.getImage(dir);

        if (!parent.exists(dir)) return null;

        return parent.memory.loadImage(dir, permanent);
    }

    public function audio(dir:String, ?permanent:Bool = false):Null<Sound>
    {
        if (parent == null) return null;

        if (parent.memory.hasAudio(dir))
            return parent.memory.getAudio(dir);

        if (!parent.exists(dir)) return null;

        return parent.memory.loadAudio(dir, permanent);
    }

    public function file(dir:String, ?permanent:Bool = false):Null<String>
    {
        if (parent == null) return null;
        
        if (parent.memory.hasFile(dir))
            return parent.memory.getFile(dir);
        
        if (!parent.exists(dir)) return null;
        
        return parent.memory.loadFile(dir, permanent);
    }

    @:nullSafety(Off)
    public function sparrowAtlas(dir:String, ?permanent:Bool = false):Null<FlxAtlasFrames>
    {
        return FlxAtlasFrames.fromSparrow(image('$dir.png', permanent), file('$dir.xml', permanent));
    }
}