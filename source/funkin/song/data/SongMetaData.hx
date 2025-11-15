package funkin.song.data;

typedef SongMetaData = 
{
    var title:String;
    var authors:Array<String>;
    var tempo:Array<SongMetaEvents<Float>>;
    var signature:Array<SongMetaEvents<Array<Int>>>;
}

typedef SongMetaEvents<T> = 
{
    var ?position:Null<Float>;
    var ?step:Null<Int>;
    var ?beat:Null<Int>;
    var data:T;
}
