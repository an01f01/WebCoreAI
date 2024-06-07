unit libmediapipe;

interface

{$mode objfpc}
{$modeswitch externalclass}
{$DEFINE NOPP}

uses
  Web, JS, Classes, Types;

type
  TMediaPipeInitOBject = class external name 'Object' (TJSObject)
    onFrame: TJSRawEventHandler;
    width: Integer;
    height: Integer;
  end;

  TMediaPipeCamera = class external name 'Camera' (TJSObject)
    constructor new (elem : TJSElement; obj: TMediaPipeInitOBject) overload;
    procedure start;
  end;

  TMediaPipeCoords = class external name 'Coords' (TJSObject)
    x: double;
    y: double;
    z: double;
  end;

  TMediaPipeLandmarks = class external name 'Landmarks' (TJSArray)
    landmarks: TJSArray;
  end;

  TMediaPipeInitHandResult = class external name 'Object' (TJSObject)
    image: TJSHTMLCanvasElement;
    multiHandLandmarks: TJSArray;
  end;

  TMediaPipeHandEventHandler = reference to function(aFile: string): string;
  TMediaPipeHandResultHandler = reference to procedure(result: TMediaPipeInitHandResult);
  TMediaPipeInitHands = class external name 'Object' (TJSObject)
    locateFile: TMediaPipeHandEventHandler;
  end;

  TMediaPipeHands = class external name 'Hands' (TJSObject)
    constructor new (obj: TMediaPipeInitHands) overload;
    procedure setOptions(obj: TJSObject);
    function send(obj: TJSObject): TJSPromise;
    procedure onResults(result: TMediaPipeHandResultHandler);
  end;

  procedure drawConnectors(context: TJSCanvasRenderingContext2D; coords: JSValue; connections: TJSArray; style: TJSObject); external name 'drawConnectors';
  procedure drawLandmarks(context: TJSCanvasRenderingContext2D; coords: JSValue; style: TJSObject); external name 'drawLandmarks';

var
  HAND_CONNECTIONS: TJSArray; external name 'HAND_CONNECTIONS';

implementation

end.
