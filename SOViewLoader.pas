unit SOViewLoader;

interface

uses
  System.Classes, FMX.Types, System.SysUtils, System.Generics.Collections,
  FMX.Controls, FMX.Ani, System.Threading, System.SyncObjs, FMX.Dialogs,
  FMX.Layouts;

type
  TViewStatus = (vsHidden, vsShowing, vsLoading);

  TViewLoader = class;

  TView<T: TControl> = class(TComponent)
  private
    FObject         : T;
    FObjectAlign    : TAlignLayout;
    FObjectPosition : TPosition;
    FObjectScale    : TPosition;
    FObjectOpacity  : Single;

    FList           : TViewLoader;
    FStatus         : TViewStatus;
    FCallback       : TProc<TObject>;
    FAni            : TFloatAnimation;
    FAni2           : TFloatAnimation;
    FAni3           : TFloatAnimation;

    procedure FOnShowFinish(sender: TObject);
    procedure FOnHideFinish(sender: TObject);
    procedure FGrowProgress(sender: TObject);

  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    function Status: TViewStatus;
    function ReloadObjectProperties: TView<T>;
    function UpdateObjectProperties: TView<T>;

    function ViewObject: T; overload;
    function ViewObject(obj: T): TView<T>; overload;
    function ViewList: TViewLoader; overload;
    function ViewList(List: TViewLoader): TView<T>; overload;

    function Show(Callback: TProc<TObject> =nil; Duration: Double=0.6): TView<T>;
    function ShowGrow(Callback: TProc<TObject> =nil; Duration: Double=0.6;
      Interpolation: TInterpolationType= TInterpolationType.Back): TView<T>;
    function ShowSlide(Callback: TProc<TObject> =nil; Duration: Double=0.6;
      Interpolation: TInterpolationType= TInterpolationType.Bounce): TView<T>;

    function Hide(Callback: TProc<TObject> =nil; Duration: Double=0.6): TView<T>;
    function HideGrow(Callback: TProc<TObject> =nil; Duration: Double=0.6;
      Interpolation: TInterpolationType= TInterpolationType.Bounce): TView<T>;
    function HideSlide(Callback: TProc<TObject> =nil; Duration: Double=0.6;
      Interpolation: TInterpolationType= TInterpolationType.Back): TView<T>;
    function HideAndRemove(Callback: TProc<TObject> =nil; Duration: Double=0.6): TView<T>;
    function HideGrowAndRemove(Callback: TProc<TObject> =nil; Duration: Double=0.6;
      Interpolation: TInterpolationType= TInterpolationType.Bounce): TView<T>;
    function HideSlideAndRemove(Callback: TProc<TObject> =nil; Duration: Double=0.6;
      Interpolation: TInterpolationType= TInterpolationType.Back): TView<T>;
    function HideAllAndShow(Callback: TProc<TObject> =nil; Duration: Double=0.6): TView<T>;
    function HideAllAndShowGrow(Callback: TProc<TObject> =nil; Duration: Double=0.6;
      Interpolation: TInterpolationType= TInterpolationType.Bounce): TView<T>;
    function HideAllAndShowSlide(Callback: TProc<TObject> =nil; Duration: Double=0.6;
      Interpolation: TInterpolationType= TInterpolationType.Back): TView<T>;
    function HideWithoutAnimation: TView<T>;
  end;

  TViewLoader = class
  private
    FParent: TFmxObject;
    ViewList: TObjectList<TObject>;
    FAni: TFloatAnimation;
    FCallback: TProc;
    procedure FOnHideAllFinish(sender: TObject);

  public
    constructor Create(AParent: TFmxObject);
    procedure Free;
    function New<T: TControl>(ViewName: String): TView<T>;

    function Count: Integer;
    function HideAll(Callback: TProc =nil; Duration: Double=0.6): TViewLoader;

    function Items<T: TControl>(index: Integer): TView<T>;
    function IndexOf(ViewName: String): Integer;
    function Find<T: TControl>(ViewName: String): TView<T>;
    function TryFind<T: TControl>(ViewName: String): TView<T>;
    procedure Remove(index: integer); overload;
    procedure Remove(ViewName: String); overload;
    function TryRemove(ViewName: String): boolean;
  end;
implementation

{ TViewLoader }

function TViewLoader.Count: Integer;
begin
  result := ViewList.Count;
end;

constructor TViewLoader.Create(AParent: TFmxObject);
begin
  inherited Create;

  FParent := AParent;

  ViewList := TObjectList<TObject>.Create;// <TComponent>.Create;
end;

function TViewLoader.Find<T>(ViewName: String): TView<T>;
var
  Index: Integer;
begin
  result := nil;

  Index := IndexOf(ViewName);
  if Index = -1 then
    raise Exception.Create(Format('View %s not found.',[Uppercase(ViewName)]));

  result := TView<T>(ViewList[Index]);
end;

procedure TViewLoader.FOnHideAllFinish(sender: TObject);
var
  I: Integer;
begin
  if Assigned(FAni) and not FAni.Running then begin
    FAni.DisposeOf;
    FAni := nil;
  end;

  for I := 0 to Count-1 do begin
    Items<TControl>(I).HideWithoutAnimation;
  end;

  With TControl(FParent) do begin
    Opacity := 1;
    Visible := True;
  end;

  if Assigned(FCallback) then
    FCallback;
  FCallback := nil;
end;

procedure TViewLoader.Free;
begin
  if assigned(ViewList) then begin
    ViewList.DisposeOf;
    ViewList := nil;
  end;

  inherited Free;
end;

function TViewLoader.HideAll(Callback: TProc; Duration: Double): TViewLoader;
begin
  result := Self;

  FCallback := Callback;

  FAni := TFloatAnimation.Create(FParent);
  FAni.Parent := FParent;
  FAni.PropertyName := 'opacity';
  FAni.StartFromCurrent := True;
  FAni.StopValue := 0.0001;
  FAni.Duration := Duration;
  FAni.OnFinish := FOnHideAllFinish;
  FAni.Start;
end;

function TViewLoader.IndexOf(ViewName: String): Integer;
begin
  result := -1;
  for var I := 0 to Count-1 do begin
    if TView<TControl>(ViewList[I]).FObject.Name = ViewName then begin
      result := I;
      break;
    end;
  end;
end;

function TViewLoader.Items<T>(index: Integer): TView<T>;
begin
  if (index<0) or (index>=Count) then
    raise Exception.Create('View not found. Index out of bounds');

  result := TView<t>(ViewList[index]);
end;

function TViewLoader.New<T>(ViewName: String): TView<T>;
var
  obj: TControl;
begin
  result := TryFind<T>(ViewName);
  if result <> nil then
    exit;

  Obj         := T.Create(FParent);
  Obj.Parent  := FParent;
  result      := TView<T>.Create(FParent);
  result.ViewObject( T(Obj) ) ;
  result.ViewList(self);
  Obj.Name    := ViewName;
  obj.Opacity := 0.001;
  obj.Visible := False;

  ViewList.Add(Result);
end;

procedure TViewLoader.Remove(ViewName: String);
var
  Index: Integer;
begin
  Index := IndexOf(ViewName);

  if Index >= 0 then
    Remove(Index)
  else
    raise Exception.Create(Format('View %s not found.',[Uppercase(ViewName)]));
end;

function TViewLoader.TryFind<T>(ViewName: String): TView<T>;
var
  Index: Integer;
begin
  Result := Nil;

  Index := IndexOf(ViewName);
  if Index > -1 then
    result := TView<T>(ViewList[Index]);
end;

function TViewLoader.TryRemove(ViewName: String): boolean;
var
  Index: Integer;
begin
  Index := IndexOf(ViewName);
  result := Index >= 0;

  if Result then
    Remove(Index);
end;

procedure TViewLoader.Remove(index: integer);
begin
  if (index<0) or (index>=Count) then
    raise Exception.Create('View not found. Index out of bounds');

  ViewList.Remove( Items<TControl>(index) );
end;

{ TView }

constructor TView<T>.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStatus := vsHidden;
end;

destructor TView<T>.Destroy;
begin
  if Assigned(FObject) then begin
    FObject.DisposeOf;
    FObject := nil;
  end;

  if Assigned(FList) then
    FList := nil;

  inherited;
end;

procedure TView<T>.FGrowProgress(sender: TObject);
var
  sX, sY, W, H, cW, cH: double;
  View: TControl;
  ViewParent: TControl;
begin
  View       := TControl(TControl(Sender).Parent);
  ViewParent := TControl(TControl(TControl(Sender).Parent).Parent);
  sX := TLayout(View).Scale.X;
  sY := TLayout(View).Scale.Y;
  w  := View.Width;
  H  := View.Height;
  cw := ViewParent.Width;
  cH := ViewParent.Height;

  View.Position.X := (cW /2) - ((W*sX)/2);
  View.Position.Y := (cH /2) - ((H*sY)/2);
end;

procedure TView<T>.FOnHideFinish(sender: TObject);
begin
  if Assigned(FAni) and not FAni.Running then begin
    FAni.DisposeOf;
    FAni := nil
  end;

  if Assigned(FAni2) and not FAni2.Running then begin
    FAni2.DisposeOf;
    FAni2 := nil
  end;

  if Assigned(FAni3) and not FAni3.Running then begin
    FAni3.DisposeOf;
    FAni3 := nil
  end;

  FStatus := vsHidden;
  TControl(FObject).Visible := False;

  if Assigned(FCallback) then
    FCallback(self);
  FCallback := nil;
end;

procedure TView<T>.FOnShowFinish(sender: TObject);
begin
  if Assigned(FAni) and not FAni.Running then begin
    FAni.DisposeOf;
    FAni := nil
  end;

  if Assigned(FAni2) and not FAni2.Running then begin
    FAni2.DisposeOf;
    FAni2 := nil
  end;

  if Assigned(FAni3) and not FAni3.Running then begin
    FAni3.DisposeOf;
    FAni3 := nil
  end;

  FStatus := vsShowing;

  if Assigned(FCallback) then
    FCallback(self);
  FCallback := nil;
end;

function TView<T>.Hide(Callback: TProc<TObject>; Duration: Double): TView<T>;
begin
  result := self;
  if not (FStatus = vsShowing) then exit;

  FCallback := Callback;

  FAni := TFloatAnimation.Create(self);
  FAni.Parent := FObject;
  FAni.PropertyName := 'opacity';
  FAni.StartFromCurrent := True;
  FAni.StopValue := 0.0001;
  FAni.Duration := Duration;
  FAni.OnFinish := FOnHideFinish;
  FAni.Start;

end;

function TView<T>.HideAllAndShow(Callback: TProc<TObject>; Duration: Double): TView<T>;
begin
  ViewList.HideAll(
    procedure begin
      Show(Callback, Duration);
    end);
end;

function TView<T>.HideAllAndShowGrow(Callback: TProc<TObject>; Duration: Double;
  Interpolation: TInterpolationType): TView<T>;
begin
  ViewList.HideAll(
    procedure begin
      ShowGrow(Callback, Duration, Interpolation);
    end);

end;

function TView<T>.HideAllAndShowSlide(Callback: TProc<TObject>;
  Duration: Double; Interpolation: TInterpolationType): TView<T>;
begin
  ViewList.HideAll(
    procedure begin
      ShowSlide(Callback, Duration, Interpolation);
    end);

end;

function TView<T>.HideAndRemove(Callback: TProc<TObject>;
  Duration: Double): TView<T>;
begin
  result := self;
  if not (FStatus = vsShowing) then begin
    ViewList.TryRemove(T(Self.FObject).Name);
    exit;
  end;

  Hide(
      procedure (Sender: TObject) begin
        ViewList.TryRemove(T(Self.FObject).Name);
      end,
      Duration);
end;

function TView<T>.HideGrow(Callback: TProc<TObject>; Duration: Double;
      Interpolation: TInterpolationType): TView<T>;
begin
  result := self;
  if not (FStatus = vsShowing) then exit;

  FCallback := Callback;

  FAni := TFloatAnimation.Create(self);
  FAni.Parent := FObject;
  FAni.PropertyName := 'Scale.X';
  FAni.StartFromCurrent := True;
  FAni.StopValue := 0.01;
  FAni.Duration := Duration;
  FAni.Interpolation := Interpolation;
  FAni.AnimationType := TAnimationType.Out;
  FAni.OnProcess := FGrowProgress;

  FAni2 := TFloatAnimation.Create(self);
  FAni2.Parent := FObject;
  FAni2.PropertyName := 'Scale.Y';
  FAni2.StartFromCurrent := True;
  FAni2.StopValue := 0.01;
  FAni2.Duration := Duration;
  FAni2.Interpolation := Interpolation;
  FAni2.AnimationType := TAnimationType.Out;
  FAni2.OnProcess := FGrowProgress;
  FAni2.OnFinish := FOnHideFinish;

  FAni.Start;
  FAni2.Start;
end;

function TView<T>.HideGrowAndRemove(Callback: TProc<TObject>; Duration: Double;
  Interpolation: TInterpolationType): TView<T>;
begin
  result := self;
  if not (FStatus = vsShowing) then begin
    ViewList.TryRemove(T(Self.FObject).Name);
    exit;
  end;

  HideGrow(
      procedure (Sender: TObject) begin
        ViewList.TryRemove(T(Self.FObject).Name);
      end,
      Duration, Interpolation);

end;

function TView<T>.HideSlide(Callback: TProc<TObject>; Duration: Double;
  Interpolation: TInterpolationType): TView<T>;
begin
  result := self;
  if not (FStatus = vsShowing) then exit;

  FCallback := Callback;

  FAni := TFloatAnimation.Create(self);
  FAni.Parent := FObject;
  FAni.PropertyName := 'Position.X';
  FAni.StartFromCurrent := True;
  FAni.StopValue := TLayout(FObject.Parent).Width + 40;
  FAni.Duration := Duration;
  FAni.Interpolation := Interpolation;
  FAni.AnimationType := TAnimationType.In;

  FAni2 := TFloatAnimation.Create(self);
  FAni2.Parent := FObject;
  FAni2.PropertyName := 'Opacity';
  FAni2.StartFromCurrent := True;
  FAni2.StopValue := 0.01;
  FAni2.Duration := Duration;
  FAni2.Interpolation := Interpolation;
  FAni2.AnimationType := TAnimationType.In;
  FAni2.OnFinish := FOnHideFinish;

  FAni.Start;
  FAni2.Start;
end;

function TView<T>.HideSlideAndRemove(Callback: TProc<TObject>; Duration: Double;
  Interpolation: TInterpolationType): TView<T>;
begin
  result := self;
  if not (FStatus = vsShowing) then begin
    ViewList.TryRemove(T(Self.FObject).Name);
    exit;
  end;

  HideSlide(
      procedure (Sender: TObject) begin
        ViewList.TryRemove(T(Self.FObject).Name);
      end,
      Duration, Interpolation);
end;

function TView<T>.HideWithoutAnimation: TView<T>;
begin
  TControl(ViewObject).Visible := False;
  FStatus := vsHidden;
end;

function TView<T>.ReloadObjectProperties: TView<T>;
begin
  result := self;

  TLayout(FObject).Align    := FObjectAlign;
  TLayout(FObject).Opacity  := FObjectOpacity;
  TLayout(FObject).Scale.Assign(FObjectScale);
  TLayout(FObject).Position.Assign(FObjectPosition);
end;

function TView<T>.Show(Callback: TProc<TObject>; Duration: Double): TView<T>;
begin
  result := self;
  if not (FStatus = vsHidden) then exit;

  ReloadObjectProperties;

  FObject.Visible := True;
  FObject.Opacity := 0.0001;
  FCallback := Callback;

  if not Assigned(FAni) then
    FAni := TFloatAnimation.Create(self);

  FAni.Parent := FObject;
  FAni.PropertyName := 'opacity';
  FAni.StartFromCurrent := True;
  FAni.StopValue := FObjectOpacity;
  FAni.Duration := Duration;
  FAni.OnFinish := FOnShowFinish;
  FAni.Start;

end;

function TView<T>.ShowGrow(Callback: TProc<TObject>; Duration: Double;
  Interpolation: TInterpolationType): TView<T>;
begin
  result := self;
  if not (FStatus = vsHidden) then exit;

  ReloadObjectProperties;

  FObject.Visible := True;
  TLayout(FObject).Scale.X := 0.01;
  TLayout(FObject).Scale.Y := 0.01;

  FCallback := Callback;

  FAni := TFloatAnimation.Create(self);
  FAni.Parent := FObject;
  FAni.PropertyName := 'Scale.X';
  FAni.StartFromCurrent := True;
  FAni.StopValue := FObjectScale.X;
  FAni.Duration := Duration;
  FAni.Interpolation := Interpolation;
  FAni.AnimationType := TAnimationType.Out;
  FAni.OnProcess := FGrowProgress;

  FAni2 := TFloatAnimation.Create(self);
  FAni2.Parent := FObject;
  FAni2.PropertyName := 'Scale.Y';
  FAni2.StartFromCurrent := True;
  FAni2.StopValue := FObjectScale.Y;
  FAni2.Duration := Duration;
  FAni2.Interpolation := Interpolation;
  FAni2.AnimationType := TAnimationType.Out;
  FAni2.OnProcess := FGrowProgress;
  FAni2.OnFinish := FOnShowFinish;

  FAni.Start;
  FAni2.Start;
end;

function TView<T>.ShowSlide(Callback: TProc<TObject>; Duration: Double;
  Interpolation: TInterpolationType): TView<T>;
begin
  result := self;
  if not (FStatus = vsHidden) then exit;

  ReloadObjectProperties;
  FObject.Visible := True;
  FObject.Opacity := 0.01;
  FObject.Position.X := TLayout(FObject.Parent).Width + 40;

  FCallback := Callback;

  FAni := TFloatAnimation.Create(self);
  FAni.Parent := FObject;
  FAni.PropertyName := 'Position.X';
  FAni.StartFromCurrent := True;
  FAni.StopValue := FObjectPosition.X;
  FAni.Duration := Duration;
  FAni.Interpolation := Interpolation;
  FAni.AnimationType := TAnimationType.Out;

  FAni2 := TFloatAnimation.Create(self);
  FAni2.Parent := FObject;
  FAni2.PropertyName := 'Opacity';
  FAni2.StartValue := 0.01;
  FAni2.StopValue := FObjectOpacity;
  FAni2.Duration := Duration*1.3;
  FAni2.Interpolation := Interpolation;
  FAni2.AnimationType := TAnimationType.Out;
  FAni2.OnFinish := FOnShowFinish;

  FAni.Start;
  FAni2.Start;
end;

function TView<T>.Status: TViewStatus;
begin
  result := FStatus;
end;

function TView<T>.UpdateObjectProperties: TView<T>;
begin
  result := Self;
  FObjectAlign    := TLayout(FObject).Align;
  FObjectOpacity  := TLayout(FObject).Opacity;
  FObjectPosition := TPosition.Create(TLayout(FObject).Position.Point) ;
  FObjectScale    := TPosition.Create(TLayout(FObject).Scale.Point);
end;

function TView<T>.ViewList(List: TViewLoader): TView<T>;
begin
  Result := Self;
  FList := List;
end;

function TView<T>.ViewList: TViewLoader;
begin
  Result := FList;
end;

function TView<T>.ViewObject(obj: T): TView<T>;
begin
  Result := Self;
  FObject := obj;

  UpdateObjectProperties;
end;

function TView<T>.ViewObject: T;
begin
  Result := FObject;
end;

end.
