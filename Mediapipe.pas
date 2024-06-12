unit Mediapipe;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, WEBLib.ExtCtrls, WEBLib.Devices, Vcl.Controls,
  WEBLib.Slider, WEBLib.JQCtrls, Vcl.StdCtrls, WEBLib.StdCtrls, Vcl.Imaging.jpeg,
  WEBLib.WebCtrls, System.Math, libmediapipe;

type
  TformMediapipe = class(TWebForm)
    WebHTMLDiv1: TWebHTMLDiv;
    lblSpeed: TWebLabel;
    lblDistance: TWebLabel;
    lblSuper: TWebLabel;
    nrSpeed: TWebLabel;
    nrDistance: TWebLabel;
    nrSuper: TWebLabel;
    speedTrack: TWebTrackBar;
    distanceTrack: TWebTrackBar;
    superTrack: TWebTrackBar;
    btnReset: TWebButton;
    WebHTMLDiv2: TWebHTMLDiv;
    imgCurrentImage: TWebImageControl;
    WebHTMLDiv3: TWebHTMLDiv;
    btnLike: TWebButton;
    btnSuper: TWebButton;
    btnDislike: TWebButton;
    WebHTMLDiv4: TWebHTMLDiv;
    WebCamera1: TWebCamera;
    canvasHand: TWebPaintBox;
    timerBackground: TWebTimer;
    timerTransform: TWebTimer;
    bntStart: TWebButton;
    procedure form1OnCreate(Sender: TObject);
    procedure btnDislikeOnClick(Sender: TObject);
    procedure btnSuperOnClick(Sender: TObject);
    procedure btnLikeOnClick(Sender: TObject);
    procedure speedTrackOnChange(Sender: TObject);
    procedure distanceTrackOnChange(Sender: TObject);
    procedure superTrackOnChange(Sender: TObject);
    procedure timerBackgroundOnTimer(Sender: TObject);
    procedure timerTransformOnTimer(Sender: TObject);
    procedure btnStartOnClick(Sender: TObject);
    procedure btnResetOnClick(Sender: TObject);
    procedure imgCurrentImageOnLoaded(Sender: TObject);
  private
    { Private declarations }
    isStartup: boolean;
    camera :TMediaPipeCamera;
    hands: TMediaPipeHands;
    [async]
    procedure doCameraOnFrame(AEvent: TJSEvent);
  public
    { Public declarations }
  end;

var
  formMediapipe: TformMediapipe;
  swipeDistanceThreshold: integer;
  swipeSpeedThreshold: integer;
  superTreshold: integer;
  likeTimeOut: TDateTime;
  videoElement: TJSElement;
  Images: TStringList;
  currentIndex: Byte;

implementation

{$R *.dfm}

procedure TformMediapipe.timerBackgroundOnTimer(Sender: TObject);
begin
  formMediapipe.Color := clWhite;
  timerBackground.enabled := False;
end;

procedure TformMediapipe.timerTransformOnTimer(Sender: TObject);
var
  randomIndex: Byte;
  currentStyle: string;
  imageElement: TJSElement;
  imagePath: string;
begin
    formMediapipe.timerTransform.Enabled := False;
  repeat
    randomIndex := RandomRange(0, Images.Count);
  until randomIndex <> currentIndex;
  currentIndex := randomIndex;

  imagePath := Images[currentIndex];
  isStartup := False;
  imgCurrentImage.ElementHandle.setAttribute('src', Images[currentIndex]);
  formMediapipe.timerTransform.Enabled := False;
end;

procedure backgroundTimer();
begin
  formMediapipe.timerBackground.Enabled := True;
end;

procedure changeBackgroundColor(color: integer);
begin
  formMediapipe.Color := color;
  backgroundTimer();
end;

procedure swipeImage(direction: string);
var
  offset : string;
  currentStyle: string;
begin
  if (direction = 'right') then
  begin
    offset := 'translateX(100%)';
  end
  else if (direction = 'left') then
  begin
    offset := 'translateX(-100%)';
  end
  else if (direction = 'up') then
  begin
    offset := 'translateY(-100%)';
  end;

  formMediapipe.imgCurrentImage.ElementHandle.style.setProperty('transform', offset);
  formMediapipe.imgCurrentImage.ElementHandle.style.setProperty('opacity', '0');

  formMediapipe.timerTransform.Enabled := True;
end;

procedure dislike();
begin
  changeBackgroundColor(clWebLightCoral);
  swipeImage('left');
end;

procedure like();
begin
  changeBackgroundColor(clMoneyGreen);
  swipeImage('right');
end;

procedure super();
begin
  changeBackgroundColor(clSkyBlue);
  swipeImage('up');
end;

procedure TformMediapipe.btnResetOnClick(Sender: TObject);
begin
  superTreshold := -2;
  swipeSpeedThreshold := 12;
  swipeDistanceThreshold := 100;
  superTrack.Position := superTreshold;
  speedTrack.Position := swipeSpeedThreshold;
  distanceTrack.Position := swipeDistanceThreshold;
  nrSuper.Caption := superTreshold.ToString;
  nrSpeed.Caption := swipeSpeedThreshold.ToString;
  nrDistance.Caption := swipeDistanceThreshold.ToString;
end;

procedure TformMediapipe.btnDislikeOnClick(Sender: TObject);
begin
  dislike();
end;

procedure TformMediapipe.btnLikeOnClick(Sender: TObject);
begin
  like();
end;

procedure TformMediapipe.btnSuperOnClick(Sender: TObject);
begin
  super();
end;

procedure TformMediapipe.doCameraOnFrame(AEvent: TJSEvent);
begin
  TAwait.ExecP<JSValue>(hands.send(new(['image', videoElement])));
end;

procedure TformMediapipe.distanceTrackOnChange(Sender: TObject);
begin
  swipeDistanceThreshold := distanceTrack.Position;
  nrDistance.Caption := swipeDistanceThreshold.ToString;
end;

procedure TformMediapipe.speedTrackOnChange(Sender: TObject);
begin
  swipeSpeedThreshold := speedTrack.Position;
  nrSpeed.Caption := swipeSpeedThreshold.ToString;
end;

procedure TformMediapipe.superTrackOnChange(Sender: TObject);
begin
  superTreshold := superTrack.Position;
  nrSuper.Caption := superTreshold.ToString;
end;

procedure TformMediapipe.btnStartOnClick(Sender: TObject);
var
  context: TJSCanvasRenderingContext2D;
  lastX : double;
  lastTime: TDateTime;
  lastLikeTime: TDateTime;
  obj: TMediaPipeInitOBject;
  handObj: TMediaPipeInitHands;
  jsObj: TJSObject;
  landmarks: TMediaPipeLandmarks;
  coords: TMediaPipeCoords;
  connectorStyleObj: TJSObject;
  landmarkStyleObj: TJSObject;
  x: double;
  z: double;
  currentTime: TDateTime;
  deltaX: double;
  deltaTime: TDateTime;
  speed: double;
begin
    videoElement := document.getElementById('input_video');
    context := canvasHand.Canvas.Context;

    obj := TMediaPipeInitOBject.new;
    obj.width := 640;
    obj.height := 360;
    obj.onFrame := doCameraOnFrame;
    camera := TMediaPipeCamera.new(videoElement, Obj);
    camera.start;

    connectorStyleObj := new([]);
    connectorStyleObj.Properties['color'] := '#00FF00';
    connectorStyleObj.Properties['lineWidth'] := 5;

    connectorStyleObj := new([]);
    connectorStyleObj.Properties['color'] := '#FF0000';
    connectorStyleObj.Properties['lineWidth'] := 2;

    jsObj := new([]);
    jsObj.Properties['selfieMode'] := 1;
    jsObj.Properties['maxNumHands'] := 1;
    jsObj.Properties['modelComplexity'] := 1;
    jsObj.Properties['minDetectionConfidence'] := 0.5;
    jsObj.Properties['minTrackingConfidence'] := 0.5;

    handObj := TMediaPipeInitHands.new;
    handObj.locateFile := function(aFile: string): string
    begin
      result:= 'https://cdn.jsdelivr.net/npm/@mediapipe/hands/' + aFile;
    end;

    hands := TMediaPipeHands.new(handObj);
    hands.setOptions(jsObj);
    hands.onResults(procedure(result: TMediaPipeInitHandResult)
    begin
      context.save;
      context.clearRect(0, 0, canvasHand.Width, canvasHand.Height);
      context.drawImage(result.image, 0, 0, canvasHand.Width, canvasHand.Height);

      if Assigned(result.multiHandLandmarks[0]) then
      begin
        landmarks := TMediaPipeLandmarks(result.multiHandLandmarks[0]);
        drawConnectors(context, landmarks, HAND_CONNECTIONS, connectorStyleObj);
        drawLandmarks(context, landmarks, landmarkStyleObj);

        coords := TMediaPipeCoords(landmarks[12]);
        x := coords.x * canvasHand.Width;
        z := coords.z;
        currentTime := Now;

        if (z < superTreshold/10) then
        begin
          if ((currentTime - lastLikeTime)*10000000 > likeTimeout) or (lastLikeTime = 0) then
          begin
            console.log((currentTime - lastLikeTime)*10000000);
            super();
            lastLikeTime := currentTime;
          end;
        end;

        if (lastX <> 0) and (lastTime <> 0) then
        begin
          deltaX := x - lastX;
          deltaTime := currentTime - lastTime;
          speed := (Abs(deltaX) / deltaTime)/10000000;
          if(speed > swipeSpeedThreshold) then
          begin
            if (Abs(deltaX) > swipeDistanceThreshold) then
            begin
              if (deltaX > 0) then
              begin
                like();
              end
              else
              begin
                dislike();
              end;
              lastX := 0;
              lastTime := 0;
            end;
          end
          else
          begin
            lastX := x;
            lastTime := currentTime;
          end;

        end
        else
        begin
          lastX := x;
          lastTime := currentTime;
        end;

      end
      else
      begin
        lastX := 0;
        lastTime := 0;
      end;

      context.restore;
    end);
end;

procedure TformMediapipe.form1OnCreate(Sender: TObject);
begin
  superTreshold := -2;
  swipeSpeedThreshold := 12;
  swipeDistanceThreshold := 100;
  likeTimeOut := 200;
  isStartup := True;
  Images := TStringList.Create;
  Images.Add('./img/cat1.jpg');
  Images.Add('./img/cat2.jpg');
  Images.Add('./img/cat3.jpg');
  Images.Add('./img/dog1.jpg');
  Images.Add('./img/dog2.jpg');
  Images.Add('./img/dog3.jpg');
  Images.Add('./img/fish1.jpg');
  Images.Add('./img/fish2.jpg');
  Images.Add('./img/fish3.jpg');
  Images.Add('./img/bird1.jpg');
  Images.Add('./img/bird2.jpg');
  Images.Add('./img/bird3.jpg');
  Images.Add('./img/rabbit1.jpg');
  Images.Add('./img/rabbit2.jpg');
  Images.Add('./img/rabbit3.jpg');
  Images.Add('./img/snake1.jpg');
  Images.Add('./img/frog1.jpg');
  Images.Add('./img/lizard1.jpg');
end;

procedure TformMediapipe.imgCurrentImageOnLoaded(Sender: TObject);
begin
  if not isStartup then
  begin
    formMediapipe.imgCurrentImage.ElementHandle.style.setProperty('transform', ' translateX(0)');
    formMediapipe.imgCurrentImage.ElementHandle.style.setProperty('opacity', '1');
  end;
end;

end.
