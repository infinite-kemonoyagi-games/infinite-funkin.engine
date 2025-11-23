package funkin.assets;

final class Paths
{
    public static function data(file:String):String
    {
        return 'assets/data/$file';
    }
    public static function images(file:String):String
    {
        return 'assets/images/$file';
    }
    public static function music(file:String):String
    {
        return 'assets/music/$file';
    }
    public static function sounds(file:String):String
    {
        return 'assets/sounds/$file';
    }
}