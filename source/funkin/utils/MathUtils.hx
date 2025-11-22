package funkin.utils;

final class MathUtils
{
    public static function floorDecimal(num:Float, precision:Float):Float
    {
        final mult:Float = Math.pow(10, precision);
        num *= mult;
        num = Math.floor(num);
        num /= mult;
        return num;
    }
}