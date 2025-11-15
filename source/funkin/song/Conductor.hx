package funkin.song;

import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.util.FlxSignal.FlxTypedSignal;

typedef InitialConductor = 
{
    tempo:Float,
    signature:TimeSignature,
    position:Float
}

typedef LastConductor = InitialConductor &
{
    steps:Int
}

class Conductor
{
    public static final DEFAULT_SIGNATURE:TimeSignature = new TimeSignature(4, 4);

    public var initialData:Null<InitialConductor> = null;
    public var lastChange:Null<LastConductor> = null;

    /**
     * count of beats that would be in a minute (also known as BPM, Beat Per Minute).
     */
    public var tempo(default, set):Float = 100.0;

    public var signature:Null<TimeSignature> = null;

    public var stepCrochet(get, never):Float;
    public var beatCrochet(get, never):Float;

    public var stepsPerBeat(default, null):Int = 4;

    public var steps(default, null):Int = 0;
    public var beats(default, null):Int = 0;
    public var sections(default, null):Int = 0;

    public var onStepUpdate(default, null):Null<FlxTypedSignal<(steps:Int) -> Void>> = null;
    public var onBeatUpdate(default, null):Null<FlxTypedSignal<(beats:Int) -> Void>> = null;
    public var onSectionUpdate(default, null):Null<FlxTypedSignal<(sections:Int) -> Void>> = null;
    
    public var reference:Null<FlxSound> = null;
    public var position(get, set):Float;

    @:noCompletion
    private var _position(null, null):Float = 0.0;

    public var offset:Float = 0.0;

    public function new(tempo:Float = 100.00, signature:Null<TimeSignature> = null)
    {
        if (signature == null) signature = Conductor.DEFAULT_SIGNATURE;

        initialData = {tempo: tempo, signature: signature, position: 0.0};

        onStepUpdate = new FlxTypedSignal();
        onBeatUpdate = new FlxTypedSignal();
        onSectionUpdate = new FlxTypedSignal();

        reset();
        signature.onChange.add(_ -> updateChanges);
    }

    public function update(elapsed:Float):Void
    {
        if (reference == null && initialData != null)
            _position += initialData.position + (elapsed * 1000);

        if (signature.denominator == 8) stepsPerBeat = 2;
        else if (signature.denominator == 4) stepsPerBeat = 4;
        else stepsPerBeat = 4; // fallback.

        final lastStep = steps;

        if (lastChange == null) steps = Math.floor((position + offset) / stepCrochet);
        else
        {
            final curPosition:Float = (position - lastChange.position) / stepCrochet;
            steps = Math.floor(curPosition + offset) + lastChange.steps;
        }
        beats = Math.floor(steps / stepsPerBeat);
        sections = Math.floor(beats / signature.numerator);

        if (lastStep < steps)
        {
            onStepUpdate.dispatch(steps);
            if (steps % stepsPerBeat == 0)
            {
                onBeatUpdate.dispatch(beats);
                if (beats % signature.numerator == 0) onSectionUpdate.dispatch(sections);
            }
        }
    }

    public function reset():Void
    {
        tempo = initialData.tempo;
        signature = initialData.signature;

        lastChange = null;
    }

    private function updateChanges():Void
    {
        if (lastChange == null) 
        {
            lastChange = {
                tempo: tempo, 
                signature: signature, 
                position: position, 
                steps: steps
            };
            return;
        }
        if (tempo != lastChange.tempo) lastChange.tempo = tempo;
        if (signature != lastChange.signature) lastChange.signature = signature;
        if (_position != lastChange.position) lastChange.position = _position;
        if (steps != lastChange.steps) lastChange.steps = steps;
    }

    @:noCompletion
    private function set_tempo(newValue:Float):Float
    {
        tempo = FlxMath.roundDecimal(newValue, 2);
        updateChanges();
        return tempo;
    }

    @:noCompletion
    private function get_position():Float
    {
        return reference != null ? reference.time : _position;
    }

    @:noCompletion
    private function set_position(newValue:Float):Float
    {
        _position = newValue;
        if (reference != null) reference.time = _position;

        updateChanges();
        return _position;
    }

    @:noCompletion
    private function get_beatCrochet():Float
    {
        return 60 / tempo * 1000;
    }

    @:noCompletion
    private function get_stepCrochet():Float
    {
        return beatCrochet / signature.numerator;
    }
}
