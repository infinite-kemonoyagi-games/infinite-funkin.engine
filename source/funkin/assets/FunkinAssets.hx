package funkin.assets;

#if sys
import sys.FileSystem;
#end

class FunkinAssets
{
    public var memory:FunkinMemory;
    public var load:FunkinLoader;

    public function new()
    {
        memory = new FunkinMemory();
        load = new FunkinLoader(this);
    }

    public function exists(dir:String):Bool 
    {
        #if sys
        return FileSystem.exists(dir);
        #else
        return OFLAssets.exists(dir, null);
        #end
    }
}