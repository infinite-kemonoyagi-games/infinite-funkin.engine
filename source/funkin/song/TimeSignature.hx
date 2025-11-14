package funkin.song;

import flixel.util.FlxSignal.FlxTypedSignal;

@:nullSafety
class TimeSignature
{
    public var numerator(default, set):Int = 4;
    public var denominator(default, set):Int = 4;

    public var onChange(default, null):Null<FlxTypedSignal<TimeSignature -> Void>> = null;

    @:nullSafety(Off)
    public function new(numerator:Int = 4, denominator:Int = 4)
    {
        this.numerator = numerator;
        this.denominator = denominator;

        onChange = new FlxTypedSignal();
    }

    @:nullSafety(Off)
    public function destroy():Void
    {
        numerator = 0;
        denominator = 0;
        onChange.destroy();
        onChange = null;
    }

    @:noCompletion
    private inline function set_numerator(newValue:Int):Int
    {
        numerator = newValue;
        if (onChange != null) onChange.dispatch(this);
        return numerator;
    }

    @:noCompletion
    private inline function set_denominator(newValue:Int):Int
    {
        denominator = newValue;
        if (onChange != null) onChange.dispatch(this);
        return denominator;
    }
}