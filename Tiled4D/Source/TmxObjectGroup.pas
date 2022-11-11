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
    FX: Single;
    FY: Single;
    FWidth: Single;
    FHeight: Single;
  public
    property Id: Integer read FId write FId;
    property Name: string read FName write FName;
    property ObjectType: string read FObjectType write FObjectType;
    property GId: Cardinal read FGId write FGId;
    property X: Single read FX write FX;
    property Y: Single read FY write FY;
    property Width: Single read FWidth write FWidth;
    property Height: Single read FHeight write FHeight;
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
