unit frame3;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit;

type
  Tfra3 = class(TFrame)
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edtInfo: TEdit;
    edtNome: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
