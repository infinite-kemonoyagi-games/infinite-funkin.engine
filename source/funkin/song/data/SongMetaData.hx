package funkin.song.data;

typedef SongMetaData = 
{
    var title:String;
    var authors:Array<String>;
    var tempo:SongMetaEvents<Float>;
    var signature:SongMetaEvents<Array<Int>>;
}

typedef SongMetaEvents<T> = 
{
    var ?step:Null<Int>;
    var ?beat:Null<Int>;
    var data:T;
}
