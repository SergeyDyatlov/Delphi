unit TmxObjectGroup;

interface

uses
  System.Types, TmxLayer, System.Generics.Collections, TmxTileLayer;

type
  TTmxObjectGroup = class;

  TTmxObject = class
  private
    FId: Integer;
    FGroup: TTmxObjectGroup;
    FName: string;
    FObjectType: string;
    FGId: Cardinal;
    FX: Double;
    FY: Double;
    FWidth: Double;
    FHeight: Double;
    FRotation: Double;
    FCell: TTmxCell;
  public
    constructor Create; overload;
    constructor Create(AId: Integer; AGroup: TTmxObjectGroup); overload;
    destructor Destroy; override;
    property Id: Integer read FId write FId;
    property Group: TTmxObjectGroup read FGroup write FGroup;
    property Name: string read FName write FName;
    property ObjectType: string read FObjectType write FObjectType;
    property GId: Cardinal read FGId write FGId;
    property X: Double read FX write FX;
    property Y: Double read FY write FY;
    property Width: Double read FWidth write FWidth;
    property Height: Double read FHeight write FHeight;
    property Rotation: Double read FRotation write FRotation;
    property Cell: TTmxCell read FCell write FCell;
  end;

  TTmxObjectGroup = class(TTmxLayer)
  private
    FObjects: TObjectList<TTmxObject>;
    FName: string;
  public
    constructor Create(const AName: string); override;
    destructor Destroy; override;
    property Name: string read FName write FName;
    property Objects: TObjectList<TTmxObject> read FObjects;
  end;

implementation

{ TTmxObjectGroup }

constructor TTmxObjectGroup.Create(const AName: string);
begin
  inherited;
  LayerType := ltObjectGroup;
  FObjects := TObjectList<TTmxObject>.Create(True);
end;

destructor TTmxObjectGroup.Destroy;
begin
  FObjects.Free;
  inherited;
end;

{ TTmxObject }

constructor TTmxObject.Create(AId: Integer; AGroup: TTmxObjectGroup);
begin
  Create;
  FId := AId;
  FGroup := AGroup;
end;

constructor TTmxObject.Create;
begin
  FCell := TTmxCell.Create;
end;

destructor TTmxObject.Destroy;
begin
  FCell.Free;
  inherited;
end;

end.
