unit formViewLoader;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Layouts, FMX.StdCtrls, FMX.Controls.Presentation, FMX.MultiView,
  frame3, frame2, frame1, FMX.Gestures, System.Actions,
  FMX.ActnList, SOViewLoader, FMX.Edit, FMX.Objects;

type
  TViewLoader_Ex = class(TForm)
    MultiView1: TMultiView;
    sbTabs: TSpeedButton;
    sbViewLoaderFrame: TSpeedButton;
    sbViewLoaderControles: TSpeedButton;
    layTabControl: TLayout;
    layViewLoaderFrame: TLayout;
    TabControl1: TTabControl;
    tbiTab1: TTabItem;
    tbiTab2: TTabItem;
    tbiTab3: TTabItem;
    fraTab1: Tfra1;
    fraTab2: Tfra2;
    fraTab3: Tfra3;
    btTabNext: TButton;
    btTabPrevious: TButton;
    btTabCliente: TButton;
    btTabFornecedor: TButton;
    btTabProduto: TButton;
    Panel1: TPanel;
    layViewLoaderControles: TLayout;
    GestureManager1: TGestureManager;
    Panel2: TPanel;
    btCustomAniHide: TButton;
    btCallbackShow: TButton;
    btCustomAniShow: TButton;
    btCallbackHide: TButton;
    btViewObjectShow: TButton;
    rbSlide: TRadioButton;
    rbGrow: TRadioButton;
    rbFade: TRadioButton;
    Label1: TLabel;
    layViewLoaderFrameContent: TLayout;
    btViewObjectHide: TButton;
    Panel3: TPanel;
    btHideImage: TButton;
    btCloneImage: TButton;
    Layout1: TLayout;
    Image1: TImage;
    procedure btTabNextClick(Sender: TObject);
    procedure btTabPreviousClick(Sender: TObject);
    procedure btTabClienteClick(Sender: TObject);
    procedure btTabFornecedorClick(Sender: TObject);
    procedure btTabProdutoClick(Sender: TObject);
    procedure sbTabsClick(Sender: TObject);
    procedure TabControl1Gesture(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btCallbackShowClick(Sender: TObject);
    procedure btCallbackHideClick(Sender: TObject);
    procedure btCustomAniShowClick(Sender: TObject);
    procedure btCustomAniHideClick(Sender: TObject);
    procedure btViewObjectShowClick(Sender: TObject);
    procedure btViewObjectHideClick(Sender: TObject);
    procedure btCloneImageClick(Sender: TObject);
    procedure btHideImageClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    vlFrame, vlControl: TViewLoader;
  end;

var
  ViewLoader_Ex: TViewLoader_Ex;

implementation

uses
  FMX.Ani;

{$R *.fmx}

procedure TViewLoader_Ex.btTabNextClick(Sender: TObject);
begin
  if TabControl1.ActiveTab.index < TabControl1.TabCount-1 then
    TabControl1.SetActiveTabWithTransition(
      TabControl1.Tabs[TabControl1.ActiveTab.Index+1],
      TTabTransition.Slide,
      TTabTransitionDirection.Normal
    );
end;

procedure TViewLoader_Ex.btHideImageClick(Sender: TObject);
begin
  vlControl.Items<TLabel>(0).HideSlideAndRemove;
end;

procedure TViewLoader_Ex.btCallbackHideClick(Sender: TObject);
begin
  if rbFade.IsChecked then begin
    vlFrame.Find<Tfra1>('fra1')
      .Hide(
        procedure (Sender: TObject)
        begin
          showmessage('Frame1 hidden with fade');
        end)
  end
  else if rbGrow.IsChecked then begin
    vlFrame.Find<Tfra1>('fra1')
      .HideGrow(
        procedure (Sender: TObject)
        begin
          showmessage('Frame1 hidden with grow');
        end)
  end
  else if rbSlide.IsChecked then begin
    vlFrame.Find<Tfra1>('fra1')
      .HideSlide(
        procedure (Sender: TObject)
        begin
          showmessage('Frame1 hidden with slide');
        end)
  end;
end;

procedure TViewLoader_Ex.btCallbackShowClick(Sender: TObject);
begin
  if rbFade.IsChecked then begin
    vlFrame.New<Tfra1>('fra1')
      .Show(
        procedure(Sender: TObject)
        begin
          showmessage('Frame1 loaded with fade');
        end)
  end
  else if rbGrow.IsChecked then begin
    vlFrame.New<Tfra1>('fra1')
      .ShowGrow(
        procedure(Sender: TObject)
        begin
          showmessage('Frame1 loaded with grow');
        end)
  end
  else if rbSlide.IsChecked then begin
    vlFrame.New<Tfra1>('fra1')
      .ShowSlide(
        procedure(Sender: TObject)
        begin
          showmessage('Frame1 loaded with slide');
        end)
  end;
end;

procedure TViewLoader_Ex.btCustomAniHideClick(Sender: TObject);
begin
  if rbFade.IsChecked then begin
    vlFrame.Find<Tfra2>('fra2')
      .Hide;
  end
  else if rbGrow.IsChecked then begin
    vlFrame.Find<Tfra2>('fra2')
      .HideGrow;
  end
  else if rbSlide.IsChecked then begin
    vlFrame.Find<Tfra2>('fra2')
      .HideSlide;
  end;

end;

procedure TViewLoader_Ex.btCustomAniShowClick(Sender: TObject);
begin
  if rbFade.IsChecked then begin
    vlFrame.New<Tfra2>('fra2')
      .Show(nil, 1.5)
  end
  else if rbGrow.IsChecked then begin
    vlFrame.New<Tfra2>('fra2')
      .ShowGrow(nil, 1.2, TInterpolationType.Elastic)
  end
  else if rbSlide.IsChecked then begin
    vlFrame.New<Tfra2>('fra2')
      .ShowSlide(nil, 1, TInterpolationType.Elastic)
  end;
end;

procedure TViewLoader_Ex.btViewObjectHideClick(Sender: TObject);
begin
  if rbFade.IsChecked then begin
    vlFrame.Find<Tfra3>('fra3')
      .Hide;
  end
  else if rbGrow.IsChecked then begin
    vlFrame.Find<Tfra3>('fra3')
      .HideGrow;
  end
  else if rbSlide.IsChecked then begin
    vlFrame.Find<Tfra3>('fra3')
      .HideSlide;
  end;

end;

procedure TViewLoader_Ex.btViewObjectShowClick(Sender: TObject);
begin
  if rbFade.IsChecked then begin
    with vlFrame.New<TFra3>('fra3').ReloadObjectProperties.ViewObject do begin
      // Visual's changes
      Align      := TAlignLayout.None;
      Scale.X    := 1;
      Scale.Y    := 1;
      Opacity    := 1;
      Position.X := 0;
      Position.Y := 0;
      Width      := 360;
      Height     := 290;

      // Content's changes
      edtInfo.Text := 'Price: R$ 5,00';
      edtNome.Text := 'My Product';
    end;

    vlFrame.Find<TFra3>('fra3')
      .UpdateObjectProperties  // necessary whenever visual changes are made
      .HideAllAndShow(nil, 1.5);
  end
  else if rbGrow.IsChecked then begin
    with vlFrame.New<TFra3>('fra3').ReloadObjectProperties.ViewObject do begin
      // Visual's changes
      Align := TAlignLayout.Client;
      Opacity := 0.6;

      // Content's changes
      edtInfo.Text := 'Price: R$ 5,00';
      edtNome.Text := 'My Product';
    end;

    vlFrame.Find<TFra3>('fra3')
      .UpdateObjectProperties  // necessary whenever visual changes are made
      .HideAllAndShowGrow(nil, 1.2, TInterpolationType.Elastic);
  end
  else if rbSlide.IsChecked then begin
    with vlFrame.New<TFra3>('fra3').ReloadObjectProperties.ViewObject do begin
      // Visual's changes
      Align := TAlignLayout.Client;
      Opacity := 1;

      // Content's changes
      edtInfo.Text := 'Price: R$ 5,00';
      edtNome.Text := 'My Product';
    end;

    vlFrame.Find<TFra3>('fra3')
      .UpdateObjectProperties  // necessary whenever visual changes are made
      .HideAllAndShowSlide(nil, 1, TInterpolationType.Elastic)
  end;

end;

procedure TViewLoader_Ex.btCloneImageClick(Sender: TObject);
begin
  with vlControl.New<TImage>('labelView'+(vlControl.Count+1).ToString).ViewObject do begin
    Position.X := 100;
    Position.Y := 100;
    Opacity := 1;
    MultiResBitmap.Assign(image1.MultiResBitmap);
  end;

  vlControl.Find<TImage>('labelView'+vlControl.Count.ToString)
    .UpdateObjectProperties
    .ShowSlide(
      procedure (sender: TObject) begin
        TAnimator.AnimateFloat(TView<Timage>(Sender).ViewObject, 'Position.Y', 400, 1);
        TAnimator.AnimateFloat(TView<Timage>(Sender).ViewObject, 'opacity', 0.6, 1);
      end);
end;

procedure TViewLoader_Ex.btTabClienteClick(Sender: TObject);
var
  dir: TTabTransitionDirection;
begin
  if TabControl1.ActiveTab.index < tbiTab1.Index  then
    dir := TTabTransitionDirection.Normal
  else
    dir := TTabTransitionDirection.Reversed;

  TabControl1.SetActiveTabWithTransition(
      tbiTab1,
      TTabTransition.Slide,
      dir
    );

end;

procedure TViewLoader_Ex.btTabFornecedorClick(Sender: TObject);
var
  dir: TTabTransitionDirection;
begin
  if TabControl1.ActiveTab.index < tbiTab2.Index  then
    dir := TTabTransitionDirection.Normal
  else
    dir := TTabTransitionDirection.Reversed;

  TabControl1.SetActiveTabWithTransition(
      tbiTab2,
      TTabTransition.Slide,
      dir
    );

end;

procedure TViewLoader_Ex.btTabPreviousClick(Sender: TObject);
begin
  if TabControl1.ActiveTab.index > 0 then
    TabControl1.SetActiveTabWithTransition(
      TabControl1.Tabs[TabControl1.ActiveTab.Index-1],
      TTabTransition.Slide,
      TTabTransitionDirection.Reversed
    );

end;

procedure TViewLoader_Ex.btTabProdutoClick(Sender: TObject);
var
  dir: TTabTransitionDirection;
begin
  if TabControl1.ActiveTab.index < tbiTab3.Index  then
    dir := TTabTransitionDirection.Normal
  else
    dir := TTabTransitionDirection.Reversed;

  TabControl1.SetActiveTabWithTransition(
      tbiTab3,
      TTabTransition.Slide,
      dir
    );

end;

procedure TViewLoader_Ex.FormCreate(Sender: TObject);
begin
  vlFrame:= TViewLoader.Create(layViewLoaderFrameContent);
  vlControl:= TViewLoader.Create(layViewLoaderControles);
end;

procedure TViewLoader_Ex.FormDestroy(Sender: TObject);
begin
  vlFrame.Free;
  vlControl.Free;
end;

procedure TViewLoader_Ex.sbTabsClick(Sender: TObject);
begin
  if sbTabs.IsPressed then begin
    layTabControl.Visible := True;
    layViewLoaderFrame.Visible := False;
    layViewLoaderControles.Visible := False;
  end
  else if sbViewLoaderFrame.IsPressed then begin
    layTabControl.Visible := False;
    layViewLoaderFrame.Visible := True;
    layViewLoaderControles.Visible := False;
  end
  else if sbViewLoaderControles.IsPressed then begin
    layTabControl.Visible := False;
    layViewLoaderFrame.Visible := False;
    layViewLoaderControles.Visible := True;
  end;
end;

procedure TViewLoader_Ex.TabControl1Gesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  case EventInfo.GestureID of
    sgiLeft:  btTabNextClick(nil);
    sgiRight: btTabPreviousClick(nil);
  end;

end;

end.
