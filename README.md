# Google MediaPipe hand gestures in TMS Web Core

![MediaPipe Logo](https://miro.medium.com/v2/resize:fit:1120/1*Hgg6bLceoIjubE2hBiJK4g.png)

Implementing machine learning in your applications can be a daunting task. However, with TMS Web Core and the vast amount of available JavaScript libraries, this can be made much easier. To demonstrate this, we have created a demo using the Google MediaPipe library. This library offers a lot of different functionalities, this includes: hand, face and language detection. These functionalities can be leveraged with their pre-trained models. In this blogpost we tackled hand landmark detection and hand position tracking within a frame. The demo can be found here on [Github](https://github.com/tmssoftware/WebCoreAI).

## Demo

For our demo, we created a Tinder-style application where you can like, dislike or super like a pet using hand gestures. The hand gestures are as follows: swipe left to dislike, swipe right to like and bring your hand closer to the camera to super like.

First of all, we need to initialize the camera, this involves creating a new camera obect and pressing the start button to capture video input.

```delphi
obj := TMediaPipeInitOBject.new;
obj.width := 640;
obj.height := 360;
obj.onFrame := doCameraOnFrame;
camera := TMediaPipeCamera.new(videoElement, Obj);
camera.start;
```

While making the new object we set an asynchronous event that attempts to recognise hands in every frame. This can be done with the HTML element of the TWebCamera.

```delphi
procedure TformMediapipe.doCameraOnFrame(AEvent: TJSEvent);
begin
  TAwait.ExecP<JSValue>(hands.send(new(['image', videoElement])));
end;
```

We need to create a new object with the settings for the MediaPipe model. This configuration will determine how the hand tracking will operate.

```delphi
jsObj := new([]);
jsObj.Properties['selfieMode'] := 1;
jsObj.Properties['maxNumHands'] := 1;
jsObj.Properties['modelComplexity'] := 1;
jsObj.Properties['minDetectionConfidence'] := 0.5;
jsObj.Properties['minTrackingConfidence'] := 0.5;
```

Next, we make a hand object which reads the necessary files needed for hand recognition.

```delphi
handObj := TMediaPipeInitHands.new;
handObj.locateFile := function(aFile: string): string
begin
  result := 'https://cdn.jsdelivr.net/npm/@mediapipe/hands/' + aFile;
end;
```

After creating all necessary objects and setting the options, we set a callback that performs a function every time a hand is recognised in a frame. In this callback, we draw circles and lines to show the landmarks and skeleton of the hand. Next we use a wrapper to get the coordinates from the top of the middlefinger.

```delphi
  TMediaPipeCoords = class external name 'Coords' (TJSObject)
    x: double;
    y: double;
    z: double;
  end;
```

With these coordinates we can do the following gestures:

1. Close in: When the z-value on your frame is smaller than the super like treshold.
2. Swipe left or right: When the hand speed is higher thean the speed treshold and the distance between this frame and the previous frame is higher than the distance treshold. 
    1. Left: When the current x-value minus the previous x-value is negative.
    2. Right: When the current x-value minus the previous x-value is positive.

And just like that we successfuly implemented hand gestures in Delphi using the Google MediaPipe library. This integration allows for a more enhanced user interaction and creates a more engaging experience. The use of machine learning and hand tracking opens up numerous possibilities for developing innovative applications that respond to human gestures.
