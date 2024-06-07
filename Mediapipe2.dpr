program Mediapipe2;



{$R *.dres}

uses
  Vcl.Forms,
  WEBLib.Forms,
  Mediapipe in 'Mediapipe.pas' {formMediapipe: TWebForm} {*.html},
  libmediapipe in 'libmediapipe.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TformMediapipe, formMediapipe);
  Application.Run;
end.
