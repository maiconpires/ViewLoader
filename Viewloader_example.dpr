program Viewloader_example;

uses
  System.StartUpCopy,
  FMX.Forms,
  SOViewLoader in 'SOViewLoader.pas',
  formViewLoader in 'formViewLoader.pas' {ViewLoader_Ex},
  frame1 in 'frame1.pas' {fra1: TFrame},
  frame2 in 'frame2.pas' {fra2: TFrame},
  frame3 in 'frame3.pas' {fra3: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TViewLoader_Ex, ViewLoader_Ex);
  Application.Run;
end.
