unit TmxObjectGroup;

interface

uses
  System.Types, TmxLayer, System.Generics.Collections;

type
  TTmxObject = class
  private
    FId: Integer;
    FName: string;
    FObjectType: string;
    FGId: Cardinal;
    FX: Double;
    FY: Double;
    FWidth: Double;
    FHeight: Double;
  public
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property ObjectType: string read FObjectType write FObjectType;
    property GId: Cardinal read FGId write FGId;
    property X: Double read FX write FX;
    property Y: Double read FY write FY;
    property Width: Double read FWidth write FWidth;
    property Height: Double read FHeight write FHeight;
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

end.
